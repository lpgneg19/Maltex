browser.contextMenus.create({
    id: "download-with-maltex",
    title: "使用 Maltex 下载",
    contexts: ["link"]
});

browser.contextMenus.onClicked.addListener((info, tab) => {
    if (info.menuItemId === "download-with-maltex") {
        const url = info.linkUrl;
        if (url) {
            browser.tabs.update(tab.id, { url: "maltex://" + url });
        }
    }
});
