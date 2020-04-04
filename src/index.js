const { prepareEmojis } = require("./emoji");

async function init() {
  await prepareEmojis();
}

init()
  .then(() => {
    process.exit(0);
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
