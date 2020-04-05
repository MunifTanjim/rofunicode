const { prepareEmojis, updateEmojiModiferBase } = require("./emoji");

async function init() {
  await prepareEmojis();
  await updateEmojiModiferBase();
}

init()
  .then(() => {
    process.exit(0);
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
