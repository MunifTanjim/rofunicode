const fs = require("fs");
const path = require("path");
const JSDOM = require("jsdom").JSDOM;
const fetch = require("node-fetch").default;

const rootDir = path.resolve(__dirname, "..");
const binDir = path.join(rootDir, "bin");
const cacheDir = path.join(rootDir, "cache");
const dataDir = path.join(rootDir, "data");

function getHexNumbersInRange(start, end) {
  const startInt = parseInt(start, 16);

  const integers = [startInt];

  if (end) {
    const endInt = parseInt(end, 16);

    for (let currInt = startInt + 1; currInt < endInt; currInt++) {
      integers.push(currInt);
    }

    integers.push(endInt);
  }

  return integers.map((number) => number.toString(16).toUpperCase());
}

async function getEmojiDataTxt() {
  const emojiDataUrl =
    "https://unicode.org/Public/13.0.0/ucd/emoji/emoji-data.txt";

  const cacheFilepath = path.join(cacheDir, "emoji-data.txt");

  if (fs.existsSync(cacheFilepath)) {
    return fs.readFileSync(cacheFilepath, "utf8");
  }

  const response = await fetch(emojiDataUrl, { method: "GET" });
  const dataTxt = await response.text();

  fs.writeFileSync(cacheFilepath, txt);

  return dataTxt;
}

async function updateEmojiModiferBase() {
  const txt = await getEmojiDataTxt();

  const codes = txt.split("\n").reduce((codes, line) => {
    const match = line.match(
      /^([0-9A-F]+)(?:\.\.([0-9A-F]+))? +; Emoji_Modifier_Base  #.+/
    );

    if (!match) {
      return codes;
    }

    const [, start, end] = match;

    return codes.concat(getHexNumbersInRange(start, end));
  }, []);

  const chars = codes.map((code) => String.fromCodePoint(`0x${code}`));

  const emojiModiferBase = `ROFUNICODE_EMOJI_MODIFIER_BASE="${chars.join("")}"`;

  const rofunicodeScriptPath = path.join(binDir, "rofunicode.sh");

  const rofunicodeScriptContent = fs.readFileSync(rofunicodeScriptPath, "utf8");
  const newRofunicodeScriptContent = rofunicodeScriptContent.replace(
    /^ROFUNICODE_EMOJI_MODIFIER_BASE=".+"$/m,
    emojiModiferBase
  );

  fs.writeFileSync(rofunicodeScriptPath, newRofunicodeScriptContent);
}

async function getEmojiListDOM() {
  const emojiListUrl = "https://unicode.org/emoji/charts-13.0/emoji-list.html";

  const filepath = path.join(cacheDir, "emoji-list.html");

  if (fs.existsSync(filepath)) {
    return JSDOM.fromFile(filepath);
  }

  const dom = await JSDOM.fromURL(emojiListUrl);

  fs.writeFileSync(filepath, dom.serialize());

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

  fs.writeFileSync(path.join(dataDir, "emojis.txt"), content);
}

module.exports.prepareEmojis = prepareEmojis;
module.exports.updateEmojiModiferBase = updateEmojiModiferBase;
