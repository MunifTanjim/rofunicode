const fs = require("fs");
const path = require("path");
const JSDOM = require("jsdom").JSDOM;

const emojiListUrl = "https://unicode.org/emoji/charts-13.0/emoji-list.html";
const sourceCachePath = path.resolve(__dirname, "..", "cache/emoji-list.html");
const targetDataPath = path.resolve(__dirname, "..", "data/emojis.txt");

async function getEmojiListDOM() {
  if (fs.existsSync(sourceCachePath)) {
    return JSDOM.fromFile(sourceCachePath);
  }

  const dom = await JSDOM.fromURL(emojiListUrl);

  fs.writeFileSync(sourceCachePath, dom.serialize());

  return dom;
}

async function prepareEmojis() {
  const {
    window: { document },
  } = await getEmojiListDOM();

  const getEmojiLine = ({ chars, tags }) => {
    const wrapper = document.createElement("div");
    const span = document.createElement("span");
    span.setAttribute("size", "0");
    span.innerHTML = tags.join(" ");
    wrapper.append(span, " ", chars);
    return wrapper.innerHTML;
  };

  const dataNodes = Array.from(document.querySelectorAll("tr")).filter((node) =>
    node.querySelector("td.code")
  );

  const emojis = [];

  for (const node of dataNodes) {
    const chars = node.querySelector("td.andr img").getAttribute("alt");

    const tags = Array.from(
      new Set(
        Array.from(node.querySelectorAll("td.name")).reduce((tags, node) => {
          return tags.concat(
            node.textContent
              .split(/[“”\(\)|: ]+/)
              .map((tag) =>
                tag.replace("’", "'").replace("⊛", "").trim().toLowerCase()
              )
              .filter(Boolean)
          );
        }, [])
      )
    ).sort();

    emojis.push(getEmojiLine({ chars, tags }));
  }

  const content = emojis.join("\n");

  fs.writeFileSync(targetDataPath, content);
}

module.exports.prepareEmojis = prepareEmojis;
