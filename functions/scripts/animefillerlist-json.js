const fs = require("fs");
const puppeteer = require("puppeteer");
const uuid = require("uuid/v4");

async function main() {
    const browser = await puppeteer.launch({
        timeout: 90000,
    });
    const page = await browser.newPage();

    await page.goto("https://www.animefillerlist.com/shows");

    const titles = (await page.$$eval(
        "#ShowList .Group ul li a",
        anchors => anchors
            .map(anchor => ({
                title: anchor.innerHTML,
                link: anchor.href,
            })),
    )).map(title => ({id: uuid(), ...title}));

    for (const title of titles) {
        console.log(`> Visiting ${title.title} page: ${title.link}`);

        await page.goto(title.link);

        try {
            title.fillerRanges = await page.$$eval("#Condensed .filler .Episodes a", buildEpisodesRange);
        } catch (e) {
            console.log(`    > ERROR: on eval "#Condensed .filler .Episodes a"`);
        }

        try {
            title.canonRanges = await page.$$eval("#Condensed .canon .Episodes a", buildEpisodesRange);
        } catch (e) {
            console.log(`    > ERROR: on eval "#Condensed .canon .Episodes a"`);
        }

        title.cover = await page.$eval(
            "#Content .Details .Left .field.field-name-field-image.field-type-image img",
            img => img.getAttribute("src"),
        );

        title.fillerInfo = await page.$eval("#Content .Details .Right .Description p", p => p.innerHTML);
        title.description = await page.$eval(
            "#Content .Details .Right .Description .field.field-name-body.field-type-text-with-summary p",
            p => p.innerHTML
        );

        title.episodes = (await page.$$eval(
            "table.EpisodeList tbody tr",
            rows => rows.map(row => {
                const episodeTypeMapping = {
                    "Mostly Canon": 1,
                    "Canon": 2,
                    "Mostly Filler": 3,
                    "Filler": 4,
                };

                const [epNumNode, titleNode, typeNode, airdateNode] = row.childNodes;
                return {
                    epNum: parseInt(epNumNode.innerHTML),
                    title: titleNode.firstChild.innerHTML,
                    link: titleNode.firstChild.href,
                    kind: episodeTypeMapping[typeNode.childNodes[0].innerHTML],
                    airdate: airdateNode.innerHTML,
                };
            }),
        )).map(episode => ({id: uuid(), ...episode}));

        title.relatedShows = await page.$$eval(
            "#Content .RelatedShows a",
            anchors => anchors.map(anchor => anchor.href),
        );

        // TODO: ver se é realmente relevante
        // for (const episode of title.episodes) {
        //     console.log(`    > Visiting episode ${episode.epNum} page: ${episode.link}`);

        //     await page.goto(episode.link);

        //     try {
        //         episode.mangaChapters = await page.$eval(
        //             ".content .field.field-name-field-manga-chapters .field-item",
        //             chapter => chapter.innerHTML,
        //             );
        //     } catch (e) {
        //         console.log(`        > ERROR: on eval ".content .field.field-name-field-manga-chapters .field-item"`);
        //     }
        // }
    }

    await browser.close();

    fs.writeFile("titles.json", JSON.stringify(titles, null, 4), "utf8", () => {});
}

function buildEpisodesRange(anchors) {
    return anchors.map(anchor => {
        const [init, end] = anchor.innerHTML.split("-").map(ri => parseInt(ri));
        return {init, end};
    });
}

main();
