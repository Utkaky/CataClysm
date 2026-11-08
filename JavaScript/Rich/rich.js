const { Client } = require("@xhayper/discord-rpc");

const appID = "1569037265169154089";
const projectName = "CataClysm";
const activity = "Working on a project";
const largeIcon = "dark";
const largeIconText = projectName;
const smallIcon = "dark";
const smallIconText = "dark";

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
