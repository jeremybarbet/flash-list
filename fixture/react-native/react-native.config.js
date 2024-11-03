const path = require("path");

const root = path.resolve(__dirname, "../../");

module.exports = {
  dependencies: {
    "@jeremybarbet/flash-list": {
      root,
      platforms: {
        ios: null,
      },
    },
  },
};
