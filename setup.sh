#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
#  Verito v0.1 — One-Click Docker Setup
#  Run: chmod +x setup.sh && ./setup.sh
# ══════════════════════════════════════════════════════════════

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     VERITO v0.1 — Docker Setup                ║${NC}"
echo -e "${CYAN}║     The missing firewall for your AI agents   ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# ── Check Docker ──
echo -e "${YELLOW}[1/4]${NC} Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}  ✗ Docker not found.${NC}"
    echo "    Install Docker Desktop: https://docs.docker.com/get-docker/"
    exit 1
fi
if ! docker info &> /dev/null 2>&1; then
    echo -e "${RED}  ✗ Docker daemon not running.${NC}"
    echo "    Open Docker Desktop and try again."
    exit 1
fi
echo -e "${GREEN}  ✓ Docker is running${NC}"

# ── Check Docker Compose ──
echo -e "${YELLOW}[2/4]${NC} Checking Docker Compose..."
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
else
    echo -e "${RED}  ✗ Docker Compose not found.${NC}"
    echo "    Install: https://docs.docker.com/compose/install/"
    exit 1
fi
echo -e "${GREEN}  ✓ Docker Compose available${NC}"

# ── Setup .env ──
echo -e "${YELLOW}[3/4]${NC} Setting up environment..."
if [ ! -f .env ]; then
    cp .env.example .env

    # Generate a random APP_SECRET_KEY
    if command -v python3 &> /dev/null; then
        SECRET=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
    elif command -v openssl &> /dev/null; then
        SECRET=$(openssl rand -base64 32 | tr -d '/+=' | head -c 43)
    else
        SECRET="replace-me-with-a-random-string-$(date +%s)"
    fi

    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|CHANGE_ME_GENERATE_A_RANDOM_STRING|$SECRET|g" .env
    else
        sed -i "s|CHANGE_ME_GENERATE_A_RANDOM_STRING|$SECRET|g" .env
    fi

    echo -e "${GREEN}  ✓ Created .env (secret key auto-generated)${NC}"
    echo ""
    echo -e "  ${YELLOW}Optional: Edit .env to add your keys:${NC}"
    echo "    NANGO_SECRET_KEY   — enables real Gmail/Slack/GitHub OAuth (get one at nango.dev)"
    echo "    TELEGRAM_BOT_TOKEN — enables write-action approvals via Telegram"
    echo ""
else
    echo -e "${GREEN}  ✓ .env already exists (skipped)${NC}"
fi

# ── Start ──
echo -e "${YELLOW}[4/4]${NC} Starting Verito + Redis..."
$COMPOSE_CMD pull --quiet 2>/dev/null || true
$COMPOSE_CMD up -d

echo ""
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Verito is running!${NC}"
echo ""
echo -e "  Dashboard:  ${CYAN}http://localhost:8000${NC}"
echo -e "  API Docs:   ${CYAN}http://localhost:8000/docs${NC}"
echo -e "  Setup:      ${CYAN}http://localhost:8000/setup${NC}"
echo -e "  Health:     ${CYAN}http://localhost:8000/health${NC}"
echo ""
echo -e "  ${YELLOW}Next step:${NC} Visit ${CYAN}http://localhost:8000/setup${NC}"
echo -e "  for copy-paste configs for Claude Desktop, Cursor, OpenClaw, etc."
echo ""
echo -e "  Stop:  ${COMPOSE_CMD} down"
echo -e "  Logs:  ${COMPOSE_CMD} logs -f verito"
echo -e "${GREEN}══════════════════════════════════════════════════${NC}"
