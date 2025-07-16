## 📞 Telegram MCP

This repository contains the Telegram MCP (Multi-Channel Platform) server, a specialized microservice within the Multi-Agent Bot system. It acts as the bridge between Telegram's webhook API and the cyrene-agent (bot-api), enabling dynamic management of multiple Telegram bots.

## ✨ Features

- **Dynamic Bot Management**: Starts and manages individual Telegram bot clients concurrently based on API keys provided by the cyrene-agent at runtime.
- **Webhook Listener**: Receives incoming messages from Telegram via webhooks.
- **Message Forwarding**: Processes incoming Telegram messages, enriches them with the correct bot ID, and forwards them to the cyrene-agent's `/telegram/webhook` endpoint for agent processing.
- **Tool Exposure**: Exposes Telegram-specific tools (e.g., `send_message_telegram`, `get_chat_history`, `get_bot_id_telegram`) via the FastMCP protocol, allowing agents to interact with Telegram.
- **Credential Injection**: Tools automatically inject the correct Telegram API credentials (token, API ID, API Hash) for the specific bot being used.
- **Modular & Scalable**: Runs as an independent microservice, allowing for easy scaling and maintenance.

## 🏛️ Architecture Context

The telegram-mcp is a crucial component for Telegram integration. Telegram sends messages to this server via webhooks. Upon receiving a message, telegram-mcp identifies the bot it's for, adds the bot's ID to the payload, and forwards it to the cyrene-agent. When an agent needs to send a message back to Telegram, it calls a telegram-mcp tool, which then uses the correct bot client to send the message.


## 🚀 Getting Started

### Prerequisites

* Python 3.12+
* **Telegram Bot Token(s)**: Obtain from [@BotFather](https://telegram.me/BotFather) on Telegram.
* **Telegram API ID & API Hash**: Obtain from [my.telegram.org](https://my.telegram.org). These are used for programmatic access.
* **ngrok**: Highly recommended for exposing your local telegram-mcp server to the internet for Telegram webhooks.

### Installation

Clone this repository:

```bash
git clone https://github.com/CyreneAI/telegram-mcp.git
cd telegram-mcp
```

> **Note:** If you are setting up the entire multi-repo system, you would typically clone the main orchestrator repository first.

Install Python dependencies:

```bash
pip install -r requirements.txt
```

### Environment Variables

Create a `.env` file in the root of this `telegram-mcp` directory with the following variable:

```env
# .env in telegram-mcp directory
BOT_API_BASE_URL=http://localhost:8000
```

* `BOT_API_BASE_URL`: The base URL of your cyrene-agent (bot-api) service.

  * Example for local development: `http://localhost:8000`
  * Example for Kubernetes (if exposed via internal cluster DNS): `http://bot-api-svc.multi-agent-bot.svc.cluster.local:8000`

### Running the Application (Local Development)

Run the telegram-mcp service:

```bash
uvicorn server:app --reload --host 0.0.0.0 --port 9003
```

The telegram-mcp server will be accessible at `http://localhost:9003`.

**Expose telegram-mcp via ngrok (Crucial for Telegram Webhooks):**

1. Open a new terminal and run ngrok to expose port 9003:

   ```bash
   ngrok http 9003
   ```
2. Copy the HTTPS URL provided by ngrok (e.g., `https://xxxxxx.ngrok-free.app`).

**Set Telegram Webhook:**

Use the `scripts/setup_webhooks.sh` script (from your main orchestrator repo) to set the webhook for your Telegram bots to point to the ngrok URL you just obtained.

> **Important:** The `setup_webhooks.sh` script must be updated to accept the ngrok URL and bot tokens as arguments.

Example command (assuming you are in the root of your main orchestrator repo):

```bash
./scripts/setup_webhooks.sh "https://xxxxxx.ngrok-free.app" "YOUR_TELEGRAM_BOT_TOKEN_FOR_AGENTX" "YOUR_TELEGRAM_BOT_TOKEN_FOR_AGENTZ"
```

This step is vital for Telegram to send messages to your telegram-mcp.

## 🧪 Usage

Once the telegram-mcp server is running, exposed via ngrok, and its tools are registered with fastmcp-core-server:

1. Create a Telegram-enabled agent via the cyrene-agent's API (e.g., using the agent-UI), providing the `telegram_bot_token`, `telegram_api_id`, and `telegram_api_hash` in the agent's secrets. This will trigger telegram-mcp to start a new Telegram bot client for that agent.
2. Chat with your Telegram bot (associated with the created agent) in Telegram.

**Expected Flow:**

1. Telegram sends message to ngrok URL.
2. ngrok forwards to telegram-mcp (port 9003).
3. telegram-mcp processes the message and forwards it (with `bot_id`) to cyrene-agent (port 8000).
4. cyrene-agent invokes the appropriate agent.
5. The agent uses `send_message_telegram` tool (exposed by telegram-mcp) to reply.
6. telegram-mcp sends the reply via the correct Telegram bot client.

## 📁 Project Structure

```
telegram-mcp/
├── .env.example
├── .gitignore
├── README.md           # <- This file
├── Dockerfile          # Dockerfile for the telegram-mcp service
├── requirements.txt    # Python dependencies for telegram-mcp
└── server.py           # FastAPI application for the telegram-mcp
```
