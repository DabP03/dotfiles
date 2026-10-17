pragma Singleton

// NetworkService.qml
// Thin logic layer over Quickshell.Networking (NetworkManager backend).
// Deliberately NOT named "Network": that would clash with the Network type
// exported by Quickshell.Networking.
//
// UI contract:
//   - wifiNetworks            : ScriptModel, sorted + deduped, bind a ListView to it
//   - acquireScan/releaseScan : call while a panel is visible (ref-counted)
//   - connectTo / disconnectFrom / forget
//   - pendingNetwork != null  : show a password prompt for that network
//   - submitPassword / cancelPassword
//   - passwordRejected        : last PSK was refused, re-prompt with an error
//   - lastError               : human-readable message, "" when none
//   - wiredDevice             : read hasLink / linkSpeed / name / address / network directly

import QtQuick
import QtQml
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    // ───────────────────────── Devices ─────────────────────────

    readonly property var wifiDevice: findDevice(DeviceType.Wifi)
    readonly property var wiredDevice: findDevice(DeviceType.Wired)

    readonly property bool hasWifi: wifiDevice !== null
    readonly property bool hasWired: wiredDevice !== null

    function findDevice(type) {
        const devs = Networking.devices.values;
        for (let i = 0; i < devs.length; i++) {
            if (devs[i].type === type)
                return devs[i];
        }
        return null;
    }

    // ───────────────────────── Global state ─────────────────────────

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled // false = rfkill hardware block
    readonly property var connectivity: Networking.connectivity

    function setWifiEnabled(on) {
        Networking.wifiEnabled = on;
    }

    function recheckConnectivity() {
        Networking.checkConnectivity();
    }

    // "wired" | "wifi" | "none" — handy for a bar icon
    readonly property string activeKind: {
        if (wiredDevice && wiredDevice.connected)
            return "wired";
        if (activeWifiNetwork)
            return "wifi";
        return "none";
    }

    // Signal strength of the connected Wi-Fi network as a real in 0.0–1.0
    // (0 when not connected to Wi-Fi). Handy for a bar icon.
    readonly property real activeSignalStrength: activeWifiNetwork ? activeWifiNetwork.signalStrength : 0

    readonly property string signalStrengthSymbol: {
        if (activeSignalStrength > .8) return "signal_wifi_4_bar" 
        else if (activeSignalStrength > .6) return "signal_wifi_3_bar" 
        else if (activeSignalStrength > .4) return "signal_wifi_2_bar"
        else if (activeSignalStrength > .2) return "signal_wifi_1_bar"
        else return "signal_wifi_statusbar_null"
    }

    // Same value for any network, e.g. in a list delegate: NetworkService.signalOf(modelData)
    function signalOf(network) {
        return network ? Number(network.signalStrength) : 0;
    }

    // ───────────────────────── Scanning (ref-counted) ─────────────────────────

    property int scanClients: 0
    readonly property bool scanning: wifiDevice ? wifiDevice.scannerEnabled : false

    function acquireScan() {
        scanClients++;
    }

    function releaseScan() {
        scanClients = Math.max(0, scanClients - 1);
    }

    Binding {
        target: root.wifiDevice
        property: "scannerEnabled"
        value: root.scanClients > 0
        when: root.wifiDevice !== null
    }

    // ───────────────────────── Wi-Fi network list ─────────────────────────

    readonly property var wifiNetworks: wifiModel

    ScriptModel {
        id: wifiModel
        values: root.buildNetworkList()
    }

    readonly property var activeWifiNetwork: {
        const dev = root.wifiDevice;
        if (!dev)
            return null;
        for (const n of dev.networks.values) {
            if (n.connected)
                return n;
        }
        return null;
    }

    // Skips hidden (empty-name) networks, dedupes by SSID (connected > known >
    // strongest signal), then sorts: connected, known, signal, name.
    function buildNetworkList() {
        const dev = root.wifiDevice;
        if (!dev)
            return [];

        const byName = new Map();
        for (const n of dev.networks.values) {
            if (!n.name)
                continue;
            const prev = byName.get(n.name);
            if (!prev || preferred(n, prev))
                byName.set(n.name, n);
        }

        const list = Array.from(byName.values());
        list.sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.known !== b.known)
                return a.known ? -1 : 1;
            if (a.signalStrength !== b.signalStrength)
                return b.signalStrength - a.signalStrength;
            return a.name.localeCompare(b.name);
        });
        return list;
    }

    function preferred(a, b) {
        if (a.connected !== b.connected)
            return a.connected;
        if (a.known !== b.known)
            return a.known;
        return a.signalStrength > b.signalStrength;
    }

    // ───────────────────────── Security helpers ─────────────────────────

    function isPskSecurity(sec) {
        return sec === WifiSecurityType.WpaPsk
            || sec === WifiSecurityType.Wpa2Psk
            || sec === WifiSecurityType.Sae;
    }

    // No secret needed to join.
    function isOpenSecurity(sec) {
        return sec === WifiSecurityType.Open || sec === WifiSecurityType.Owe;
    }

    // True if this panel can actually join the network: open, PSK-based,
    // or already has a saved profile (enterprise/WEP only work if known).
    function canConnect(network) {
        if (!network)
            return false;
        return network.known || isOpenSecurity(network.security) || isPskSecurity(network.security);
    }

    function securityLabel(network) {
        return WifiSecurityType.toString(network.security);
    }

    // WPA passphrases are 8–63 chars, or exactly 64 hex digits for a raw key.
    function passwordLooksValid(psk) {
        if (psk.length >= 8 && psk.length <= 63)
            return true;
        return psk.length === 64 && /^[0-9a-fA-F]+$/.test(psk);
    }

    // ───────────────────────── Connect / disconnect / password flow ─────────────────────────

    property var pendingNetwork: null   // WifiNetwork waiting for a password
    property bool passwordRejected: false
    property string lastError: ""
    property bool awaitingPsk: false    // true between submitPassword() and its result

    function connectTo(network) {
        if (!network || network.connected || network.stateChanging)
            return;

        lastError = "";
        passwordRejected = false;
        awaitingPsk = false;
        if (pendingNetwork && pendingNetwork !== network)
            pendingNetwork = null;

        if (!canConnect(network)) {
            lastError = `"${network.name}" uses ${securityLabel(network)}, which can't be set up here`;
            return;
        }

        // Always try plain connect() first: saved networks (and open ones) succeed
        // without a prompt. A NoSecrets failure triggers the password flow below.
        network.connect();
    }

    function disconnectFrom(network) {
        if (!network)
            return;
        if (pendingNetwork === network)
            cancelPassword();
        network.disconnect();
    }

    function forget(network) {
        if (!network)
            return;
        if (pendingNetwork === network)
            cancelPassword();
        network.forget();
    }

    function submitPassword(psk) {
        if (!pendingNetwork || !psk)
            return;
        lastError = "";
        passwordRejected = false;
        awaitingPsk = true;
        pendingNetwork.connectWithPsk(psk);
    }

    function cancelPassword() {
        pendingNetwork = null;
        passwordRejected = false;
        awaitingPsk = false;
    }

    function clearError() {
        lastError = "";
    }

    function handleFailure(network, reason) {
        if (reason === ConnectionFailReason.NoSecrets) {
            if (isPskSecurity(network.security)) {
                // NoSecrets right after we submitted a PSK means it was wrong.
                passwordRejected = (pendingNetwork === network && awaitingPsk);
                awaitingPsk = false;
                pendingNetwork = network;
                lastError = "";
            } else {
                cancelPassword();
                lastError = `"${network.name}" needs credentials this panel can't provide (${securityLabel(network)})`;
            }
            return;
        }

        awaitingPsk = false;
        lastError = failureText(reason);
    }

    function failureText(reason) {
        switch (reason) {
        case ConnectionFailReason.NoSecrets:
            return "Password required";
        case ConnectionFailReason.WifiClientFailed:
            return "Wi-Fi supplicant failed";
        case ConnectionFailReason.WifiAuthTimeout:
            return "Authentication timed out";
        case ConnectionFailReason.WifiNetworkLost:
            return "Network not found";
        case ConnectionFailReason.WifiClientDisconnected:
            return "Wi-Fi supplicant disconnected";
        default:
            return "Connection failed";
        }
    }

    // Close the prompt once the pending network actually connects.
    Connections {
        target: root.pendingNetwork

        function onConnectedChanged() {
            if (root.pendingNetwork && root.pendingNetwork.connected)
                root.cancelPassword();
        }
    }

    // One Connections per Wi-Fi network to catch connectionFailed(reason).
    Instantiator {
        model: root.wifiDevice ? root.wifiDevice.networks : null

        delegate: Connections {
            target: modelData

            function onConnectionFailed(reason) {
                root.handleFailure(modelData, reason);
            }
        }
    }
}
