require("translator")

local FALLBACK_LANGUAGE = "en"

local TRANSLATIONS = {
    four = {
        en = "skins",
        ru = "скина",
    },
    many = {
        en = "skins",
        ru = "скинов",
    },
    one = {
        en = "skin",
        ru = "скин",
    },
}

local SUPPORTED_LANGUAGES = {
    en = true,
    ru = true,
}

local function GetLanguage()
    local lang = GLOBAL.LanguageTranslator and GLOBAL.LanguageTranslator.defaultlang or FALLBACK_LANGUAGE
    local isLanguageSupported = SUPPORTED_LANGUAGES[lang]
    lang = (isLanguageSupported ~= nil and isLanguageSupported) and lang or FALLBACK_LANGUAGE
    return lang
end

local LANGUAGE = GetLanguage()

local function GetSkinsLocString(amount)
    if amount == nil or amount < 1 or amount > 4 then
        return TRANSLATIONS["many"][LANGUAGE]
    end
    if amount == 1 then
        return TRANSLATIONS["one"][LANGUAGE]
    end
    return TRANSLATIONS["four"][LANGUAGE]
end

AddClassPostConstruct("widgets/hoverer", function(self, font, size, text)
    self.lastTarget = nil
    self.lastTargetSkinsAmount = 0
    local OldOnUpdate = self.OnUpdate
    self.OnUpdate = function(self, dt)
        local target = GLOBAL.TheInput:GetWorldEntityUnderMouse()
        if target ~= self.lastTarget then
            self.lastTarget = target
            self.lastTargetSkinsAmount = 0
            local prefab = self.lastTarget ~= nil and self.lastTarget.prefab or nil
            if prefab ~= nil then
                local skinList = GLOBAL.PREFAB_SKINS[prefab]
                if skinList ~= nil then
                    for _, skin in ipairs(skinList) do
                        if not GLOBAL.PREFAB_SKINS_SHOULD_NOT_SELECT[skin] and GLOBAL.TheInventory:CheckOwnership(skin) then
                            self.lastTargetSkinsAmount = self.lastTargetSkinsAmount + 1
                        end
                    end
                end
            end
        end
        OldOnUpdate(self, dt)
        if self.lastTargetSkinsAmount > 0 and self.str ~= nil then
            self.text:SetString(self.str .. "\n" .. GLOBAL.tostring(self.lastTargetSkinsAmount) .. " " .. GetSkinsLocString(self.lastTargetSkinsAmount))
        end
    end
end)
