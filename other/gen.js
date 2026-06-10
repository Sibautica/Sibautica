import fs from "fs"
import path from "path"
import url from "url"

const __filename = url.fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const locPath = path.join(__dirname, "loc.json")
const locData = JSON.parse(fs.readFileSync(locPath, "utf-8"))

const langs = locData.languages
const locales = locData.locales
 fs.writeFileSync(path.join(__dirname, "langlist.txt"), "")
const genLangList = (langlist) => {
langlist.forEach((lang) => {
   
    const langName = lang.name
    const langCode = lang.code
    fs.appendFileSync(path.join(__dirname, "langlist.txt"), `${langCode} ${langName}\n`)
})
}

const genNativeLocales = (locales, langlist ) => {
    locales.forEach((locale) => {
        const localeName = locale.name
        fs.writeFileSync(path.join(__dirname,  `loc${localeName}.txt`), "")
        const localePath = path.join(__dirname,  `loc${localeName}.txt`)
        const localeData = locale.locale
        localeData.forEach((data, index) => {
            const langCode = langlist[index].code
            fs.appendFileSync(localePath, `${langCode} ${data}\n`)
        })
        
    })
}


genLangList(langs)
genNativeLocales(locales.filter(x => x.native), langs)