import DiscordJS from "discord.js";
import dotenv from "dotenv";
import { Octokit } from "@octokit/rest";
import { getModal } from "./utils";
dotenv.config();

const client = new DiscordJS.Client({
    intents: [DiscordJS.GatewayIntentBits.Guilds, DiscordJS.GatewayIntentBits.GuildMessages],
});

client.on("clientReady", () => {
    console.log("issue bot ready");
    debugger; // This will pause execution when debugging
    const guildId = process.env.GUILD_ID || "";

    const guild = client.guilds.cache.get(guildId);

    let commands;

    if (guild) {
        commands = guild.commands;
    } else {
        commands = client.application?.commands;
    }

    commands?.create({
        name: "Open github issue",
        type: DiscordJS.ApplicationCommandType.Message,
    });
});

client.on("interactionCreate", async (interaction) => {
    if (interaction.isMessageContextMenuCommand()) {
        const { commandName, targetMessage } = interaction;
        if (commandName === "Open github issue") {
            // Extract thread/forum post title if the message is from a thread
            let messageContent = targetMessage.content;
            
            // Fetch the channel using channelId since targetMessage.channel might be null
            const channel = await client.channels.fetch(targetMessage.channelId);
            let threadTitle = "";

            if (channel?.isThread()) {
                const thread = channel;
                threadTitle = thread.name;
            }
            
            // Create message link
            const messageLink = `https://discord.com/channels/${interaction.guildId}/${targetMessage.channelId}/${targetMessage.id}`;
            
            // Add message link to the description
            const descriptionWithLink = `[View original message](${messageLink})\n\n${messageContent}`;
            
            const modal = getModal(threadTitle, descriptionWithLink);
            interaction.showModal(modal);
        }
    } else if (interaction.isModalSubmit()) {
        const { fields } = interaction;
        const issueTitle = fields.getField("issueTitle").value;
        const issueDescription = fields.getField("issueDescription").value;
        const octokit = new Octokit({
            auth: process.env.GITHUB_ACCESS_TOKEN,
            baseUrl: "https://api.github.com",
        });

        octokit.rest.issues
            .create({
                owner: process.env.GITHUB_USERNAME || "",
                repo: process.env.GITHUB_REPOSITORY || "",
                title: issueTitle,
                body: issueDescription,
            })
            .then((res) => {
                interaction.reply(`Issue created: ${res.data.html_url}`);
            });
    }
});

client.login(process.env.BOT_TOKEN);
