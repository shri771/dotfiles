#!/bin/bash
# GNOME Keyring Diagnostic and Status Check Script

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         GNOME Keyring Diagnostic Tool for NixOS               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ "$1" = "OK" ]; then
        echo -e "${GREEN}✓${NC} $2"
    elif [ "$1" = "WARN" ]; then
        echo -e "${YELLOW}⚠${NC} $2"
    elif [ "$1" = "ERROR" ]; then
        echo -e "${RED}✗${NC} $2"
    else
        echo -e "${BLUE}ℹ${NC} $2"
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. CHECKING GNOME KEYRING DAEMON PROCESS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if pgrep -f "gnome-keyring-daemon" > /dev/null; then
    print_status "OK" "gnome-keyring-daemon is RUNNING"
    echo ""
    echo "   Process details:"
    ps aux | grep "[g]nome-keyring-daemon" | while read line; do
        echo "   $line"
    done
    echo ""
    # Check what components it's running with
    DAEMON_CMD=$(ps aux | grep "[g]nome-keyring-daemon" | awk '{for(i=11;i<=NF;i++) printf $i" "; print ""}')
    echo "   Command: $DAEMON_CMD"

    if echo "$DAEMON_CMD" | grep -q "components=secrets"; then
        print_status "OK" "Running with 'secrets' component (password storage)"
    else
        print_status "WARN" "NOT running with 'secrets' component"
    fi

    if echo "$DAEMON_CMD" | grep -q "ssh"; then
        print_status "OK" "Running with 'ssh' component (SSH key management)"
    else
        print_status "WARN" "NOT running with 'ssh' component"
    fi

    if echo "$DAEMON_CMD" | grep -q "pkcs11"; then
        print_status "OK" "Running with 'pkcs11' component (certificate storage)"
    else
        print_status "WARN" "NOT running with 'pkcs11' component"
    fi
else
    print_status "ERROR" "gnome-keyring-daemon is NOT RUNNING"
    echo ""
    print_status "INFO" "The daemon should be started with:"
    echo "   gnome-keyring-daemon --start --components=secrets,ssh,pkcs11"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. CHECKING ENVIRONMENT VARIABLES"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -n "$GNOME_KEYRING_CONTROL" ]; then
    print_status "OK" "GNOME_KEYRING_CONTROL is set: $GNOME_KEYRING_CONTROL"
    if [ -d "$GNOME_KEYRING_CONTROL" ]; then
        print_status "OK" "Control directory exists"
        ls -la "$GNOME_KEYRING_CONTROL" 2>/dev/null | sed 's/^/   /'
    else
        print_status "ERROR" "Control directory does not exist!"
    fi
else
    print_status "ERROR" "GNOME_KEYRING_CONTROL is NOT SET"
    echo "   This variable tells apps where to find the keyring socket"
fi

echo ""

if [ -n "$SSH_AUTH_SOCK" ]; then
    print_status "OK" "SSH_AUTH_SOCK is set: $SSH_AUTH_SOCK"
    if [ -S "$SSH_AUTH_SOCK" ]; then
        print_status "OK" "SSH socket exists and is valid"
    else
        print_status "WARN" "SSH socket does not exist or is not a socket"
    fi
else
    print_status "WARN" "SSH_AUTH_SOCK is NOT SET"
    echo "   This is needed for SSH key management"
fi

echo ""

if [ -n "$GNOME_KEYRING_PID" ]; then
    print_status "OK" "GNOME_KEYRING_PID is set: $GNOME_KEYRING_PID"
else
    print_status "WARN" "GNOME_KEYRING_PID is NOT SET (optional but recommended)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. CHECKING SYSTEMD USER SERVICE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if systemctl --user list-unit-files | grep -q "gnome-keyring.service"; then
    print_status "OK" "gnome-keyring.service exists"
    SERVICE_STATUS=$(systemctl --user is-active gnome-keyring.service 2>/dev/null)

    if [ "$SERVICE_STATUS" = "active" ]; then
        print_status "OK" "Service is ACTIVE"
    else
        print_status "ERROR" "Service is $SERVICE_STATUS (should be active)"
    fi

    echo ""
    echo "   Service details:"
    systemctl --user status gnome-keyring.service --no-pager 2>/dev/null | sed 's/^/   /'
else
    print_status "WARN" "gnome-keyring.service not found in systemd user services"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. CHECKING DBUS ACTIVATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

DBUS_SERVICE="org.gnome.keyring"
if busctl --user list | grep -q "$DBUS_SERVICE"; then
    print_status "OK" "GNOME Keyring is registered on D-Bus"
    busctl --user list | grep "$DBUS_SERVICE" | sed 's/^/   /'
else
    print_status "WARN" "GNOME Keyring NOT found on D-Bus"
    echo "   Apps communicate with keyring through D-Bus"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. CHECKING KEYRING DATA DIRECTORY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

KEYRING_DIR="$HOME/.local/share/keyrings"
if [ -d "$KEYRING_DIR" ]; then
    print_status "OK" "Keyring data directory exists: $KEYRING_DIR"
    echo ""
    echo "   Keyrings found:"
    ls -lh "$KEYRING_DIR"/*.keyring 2>/dev/null | awk '{print "   " $9}' || echo "   No .keyring files found"

    if [ -f "$KEYRING_DIR/login.keyring" ]; then
        print_status "OK" "Default 'login' keyring exists"
    else
        print_status "WARN" "Default 'login' keyring NOT found"
        echo "   This is the main keyring that should unlock on login"
    fi
else
    print_status "WARN" "Keyring data directory does not exist"
    echo "   Directory should be created on first use"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. CHECKING PAM CONFIGURATION (System-level)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "/etc/pam.d/login" ]; then
    if grep -q "pam_gnome_keyring.so" /etc/pam.d/login; then
        print_status "OK" "PAM is configured for login"
    else
        print_status "ERROR" "PAM NOT configured for login"
        echo "   Add to /etc/nixos/configuration.nix:"
        echo "   security.pam.services.login.enableGnomeKeyring = true;"
    fi
else
    print_status "WARN" "/etc/pam.d/login not found"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "7. FUNCTIONAL TEST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if secret-tool is available
if command -v secret-tool &> /dev/null; then
    print_status "OK" "secret-tool is available"
    echo ""
    echo "   Testing keyring access..."

    # Try to store a test secret
    TEST_VALUE="test_$(date +%s)"
    if echo "$TEST_VALUE" | secret-tool store --label='Diagnostic Test' test_key diagnostic 2>/dev/null; then
        print_status "OK" "Successfully stored test secret"

        # Try to retrieve it
        RETRIEVED=$(secret-tool lookup test_key diagnostic 2>/dev/null)
        if [ "$RETRIEVED" = "$TEST_VALUE" ]; then
            print_status "OK" "Successfully retrieved test secret"
            print_status "OK" "KEYRING IS WORKING!"
        else
            print_status "ERROR" "Could not retrieve test secret"
        fi

        # Clean up
        secret-tool clear test_key diagnostic 2>/dev/null
    else
        print_status "ERROR" "Could not store test secret"
        print_status "ERROR" "KEYRING IS NOT WORKING PROPERLY"
    fi
else
    print_status "WARN" "secret-tool not available (install libsecret to test)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "8. SUMMARY & RECOMMENDATIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Determine overall status
DAEMON_RUNNING=$(pgrep -f "gnome-keyring-daemon" > /dev/null && echo "yes" || echo "no")
ENV_SET=$([ -n "$GNOME_KEYRING_CONTROL" ] && echo "yes" || echo "no")
SERVICE_ACTIVE=$(systemctl --user is-active gnome-keyring.service 2>/dev/null)

if [ "$DAEMON_RUNNING" = "yes" ] && [ "$ENV_SET" = "yes" ]; then
    print_status "OK" "GNOME Keyring appears to be set up correctly!"
    echo ""
    echo "   Your keyring should work with:"
    echo "   • GParted (polkit authentication)"
    echo "   • Vivaldi/Chrome (password storage)"
    echo "   • SSH keys (if using ssh component)"
    echo "   • Any app that uses libsecret"
elif [ "$DAEMON_RUNNING" = "yes" ] && [ "$ENV_SET" = "no" ]; then
    print_status "ERROR" "Daemon is running but environment variables are not set"
    echo ""
    echo "   FIX: Start the daemon with eval:"
    echo "   eval \$(gnome-keyring-daemon --start --components=secrets,ssh,pkcs11)"
    echo ""
    echo "   Add this to your Hyprland startup script"
else
    print_status "ERROR" "GNOME Keyring is not properly configured"
    echo ""
    echo "   RECOMMENDED FIXES:"
    echo "   1. Enable in home-manager (~/.config/home-manager/home.nix):"
    echo "      services.gnome-keyring.enable = true;"
    echo ""
    echo "   2. Enable PAM in system config (/etc/nixos/configuration.nix):"
    echo "      security.pam.services.login.enableGnomeKeyring = true;"
    echo ""
    echo "   3. Add startup script to hyprland.conf:"
    echo "      exec-once = eval \$(gnome-keyring-daemon --start --components=secrets,ssh,pkcs11)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "End of diagnostic"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
