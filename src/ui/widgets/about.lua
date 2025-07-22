local app = require("app")
local csp = require("csp")
local cui = require("ui.cui")

local aboutWidget = {}

local vrcLogoFullImage = "assets\\img\\vrc_logo_full.png"

function aboutWidget.body()
        cui.offsetCursorX(15)
        cui.offsetCursorY(10)

        ui.pushTextWrapPosition(ui.windowWidth() - 15 * cui.scale())

        cui.snapCursor()
        ui.dwriteText(
                [[ACUIR is a Lua-based user interface for Assetto Corsa developed by Virtual Racing Cars, designed to enhance the in-game experience with a more modern approach than the base game.

Whilst initially this project was created merely as a main menu UI replacement, it has taken on a bit more than that initial goal. As time progresses, more features that before, would require a directory full of separate apps, will become available natively within ACUIR itself. The end goal; a cohesive one-stop solution that will hopefully solve most of the more basic shortcomings of the general user experience in Assetto Corsa.

This project is open-source and welcomes contributions from the community. If you have suggestions, bug reports, or would like to contribute, please visit the GitHub repository at https://github.com/virtual-racing-cars/acuir.

We would also like to thank the early testers of ACUIR for their invaluable feedback and patience during the development process.

Contributions
- ACUIR Developer: William Gawlik (Schmawlik)
- ACUIR Audio: Mike Krybus (imrimike)
- ACUIR Testers: Dan Mezza, Damgam, Flashsacs, airwaves, benjamin00, Underchosen, Nиco, Kody Laurence, KiboOst, Max225
- Assetto Corsa: Kunos Simulazioni
- Custom Shaders Patch: x4fab, Jackson Papageorge, Dmitrii A, henter, Neoned, Stereo

ACUIR version: %s
CSP version: %s
]] % { app.version, csp.versionNumerical },
                20 * cui.scale()
        )

        ui.setCursorX(0)

        local vrcLogoFullImageSize = ui.imageSize(vrcLogoFullImage) * cui.scale() * 0.25

        ui.setCursorX(ui.windowWidth() * 0.5 - vrcLogoFullImageSize.x * 0.5)
        ui.offsetCursorY(ui.availableSpaceY() * 0.5 - vrcLogoFullImageSize.y * 0.5)

        ui.image(vrcLogoFullImage, vrcLogoFullImageSize)
end

return aboutWidget
