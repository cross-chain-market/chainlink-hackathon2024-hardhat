
const { network, run } = require("hardhat")


async function main() {
    await run("compile");
}

main().catch((error) => {
    console.error(error)
    process.exitCode = 1
})
