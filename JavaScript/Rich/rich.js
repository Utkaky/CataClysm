const { Client } = require("@xhayper/discord-rpc");

const appID = "1568689589105856643";
const projectName = "My Project";
const activity = "Working on a project";
const largeIcon = "app_icon";
const largeIconText = projectName;
const smallIcon = "";
const smallIconText = "";

const client = new Client({ clientId: appID });
const startedAt = new Date();

client.on("ready", async () => {
  console.log("Discord Rich Presence connected.");

  try {
    await client.user?.setActivity({
      details: projectName,
      state: activity,
      startTimestamp: startedAt,
      largeImageKey: largeIcon,
      largeImageText: largeIconText,
      ...(smallIcon ? { smallImageKey: smallIcon } : {}),
      ...(smallIconText ? { smallImageText: smallIconText } : {}),
    });
  } catch (error) {
    console.error("Could not set Discord activity:", error.message);
  }
});

client.login().catch((error) => {
  console.error("Could not connect to Discord. Make sure Discord is running:", error.message);
  process.exitCode = 1;
});
