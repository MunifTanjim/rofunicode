const { prepareEmojis, updateEmojiModiferBase } = require("./emoji");

const unicodeVersion = "15.0.0";

async function init() {
  await prepareEmojis(unicodeVersion);
  await updateEmojiModiferBase(unicodeVersion);
}

init()
  .then(() => {
    process.exit(0);
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
