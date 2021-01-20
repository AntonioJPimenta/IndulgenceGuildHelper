--Initialize addon saved variables tables, if non existing
frameAddOnLoad = CreateFrame("FRAME");
frameAddOnLoad:RegisterEvent("ADDON_LOADED");
frameAddOnLoad:RegisterEvent("PLAYER_LOGOUT");

function frameAddOnLoad:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "IndulgenceGuildHelper" then
        if indMatDeposits == nill then indMatDeposits = { } end
        if indGoldDeposits == nill then indGoldDeposits = { } end
        if indGoldDepositsDate == nill then indGoldDepositsDate = { } end
    end
end

frameAddOnLoad:SetScript("OnEvent", frameAddOnLoad.OnEvent);

--Register addon message channel
pName, pRealm = UnitName("player")
realmName = GetRealmName()
addOnPrefix = "IDG";
successfulRequest = C_ChatInfo.RegisterAddonMessagePrefix(addOnPrefix);
isRegistered = C_ChatInfo.IsAddonMessagePrefixRegistered(addOnPrefix)
chatType = "GUILD"
frameAddonMSG = CreateFrame("Frame")
frameAddonMSG:RegisterEvent("CHAT_MSG_ADDON")

function frameAddonMSG_OnEvent(self, event, prefix, msg, channel, sName, sRealms, ...)
    if event == "CHAT_MSG_ADDON" and prefix == addOnPrefix then
        if strsub(msg, 1, 1) == "M" then
            local logBankInfo, logBankWho, logBankWhoRealm, logBankAction, logBankAmmount = strsplit(";", msg, 5)
        end
	end
end

frameAddonMSG:SetScript("OnEvent", frameAddonMSG_OnEvent)

--Register addon slash commands
SLASH_IDG1 = "/idg"
SLASH_IDG2 = "/ind"

function idgHelper(args)
    if #(args) == 0 then
        infoPrint("|cff00FF00Valid arguments:\n|cff7700FFwipe|r - Wipes local saved data", true)
    elseif strupper(args) == "LOGS" then
        local fullMessage = ""

        infoPrint("|cff00FF00Mats Log:", true)
        for index = 1, #(indMatDeposits) do
            fullMessage = strjoin("\n", fullMessage, indMatDeposits[index])
            print(indMatDeposits[index]);
        end
        infoPrint("|cff00FF00Money Log:")
        for index = 1, #(indGoldDeposits) do
            local logBankInfo, logBankWho, logBankWhoRealm, logBankAction, logBankAmmount = strsplit(";", indGoldDeposits[index], 5)
            print(logBankWho .. "-" .. logBankWhoRealm .. " " .. logBankAction .. " " .. GetCoinTextureString(logBankAmmount))
        end
    elseif strupper(args) == "WIPE" then
        StaticPopupDialogs["indWipeData"] = {
            text = "Indulgence Guild Helper - Are you sure you want to wipe your saved data?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                wipe(indMatDeposits)
                wipe(indGoldDeposits)
                wipe(indGoldDepositsDate)
                infoPrint("|cff00FF00Saved data wiped.", true)
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show ("indWipeData")
    end
end

SlashCmdList["IDG"] = idgHelper;

local logMMessage = ""
local logGMessage = ""

local igtType, igtName, igitemLink, igcount, igtab1, igtab2, igyear, igmonth, igday, ighour;
local updateCount = 0;
local tab = 0;
local intCount = 0

guildBankFrame = CreateFrame("Frame","evFrame",UIParent);
guildBankFrame:RegisterEvent( "GUILDBANKBAGSLOTS_CHANGED" );
guildBankFrame:RegisterEvent( "GUILDBANKFRAME_CLOSED" );
guildBankFrame:RegisterEvent( "GUILDBANKFRAME_OPENED" );
guildBankFrame:RegisterEvent( "GUILDBANKLOG_UPDATE" );
guildBankFrame:RegisterEvent( "GUILDBANK_ITEM_LOCK_CHANGED" );
guildBankFrame:RegisterEvent( "GUILDBANK_UPDATE_MONEY" );
guildBankFrame:RegisterEvent( "GUILDBANK_UPDATE_TABS" );
guildBankFrame:RegisterEvent( "GUILDBANK_UPDATE_WITHDRAWMONEY" );

local intCountEventsOpen = 0;
local bolUpdateMoney = false;
local bolUpdateWithdrawMoney = false;
local bolConsistency = true;

function guildBankFrame_OnEvent(self,event,...)
    if (event == "GUILDBANK_UPDATE_MONEY") then
        bolUpdateMoney = true
    elseif (event == "GUILDBANK_UPDATE_WITHDRAWMONEY" and bolUpdateMoney) then
        bolUpdateWithdrawMoney = true;
        for tab = 1,GetNumGuildBankTabs() do
            QueryGuildBankLog(tab);
            QueryGuildBankTab(tab);
        end		
        QueryGuildBankLog(MAX_GUILDBANK_TABS+1);
    elseif ( event == "GUILDBANKFRAME_OPENED" ) then
        intCountEventsOpen = intCountEventsOpen + 1;
        updateCount = 0;
        for tab = 1,GetNumGuildBankTabs() do
            QueryGuildBankLog(tab);
            QueryGuildBankTab(tab);
        end		
        QueryGuildBankLog(MAX_GUILDBANK_TABS+1);
    elseif (event == "GUILDBANKLOG_UPDATE") then
        updateCount = updateCount + 1;
        bolConsistency = true
        if updateCount == GetNumGuildBankTabs() + 1 then
            intTempTransNum = GetNumGuildBankMoneyTransactions();
            if not bolUpdateWithdrawMoney then
                if intTempTransNum > #(indGoldDeposits) then
                    wipe(indGoldDeposits)
                    for trans = 1, intTempTransNum do
                        igtType, igtName, igamount, igyears, igmonths, igdays, ighours = GetGuildBankMoneyTransaction(trans);
                        if igtType ~= "depositSummary" then
                            local tmpRealmName = strfind(igtName, "-")
                            if tmpRealmName == nil then
                                logGMessage = "G;" .. igtName .. ";" .. realmName .. ";" .. igtType .. ";" .. igamount
                            else
                                local tmpPlayerName = strsub(igtName, 1, strfind(igtName, "-") - 1)
                                local tmpRealmName = strsub(igtName, strfind(igtName, "-") + 1, #igtName)
                                logGMessage = "G;" .. tmpPlayerName .. ";" .. tmpRealmName .. ";" .. igtType .. ";" .. igamount
                            end
                            if indGoldDeposits[trans] ~= logGMessage then
                                tinsert(indGoldDeposits, logGMessage)
                                tinsert(indGoldDepositsDate, igtType ..";" .. igtName ..";" .. igamount ..";" .. igyears ..";" .. igmonths ..";" .. igdays ..";" .. ighours .. ";" .. date())
                            end
                        end
                    end
                elseif intTempTransNum == #(indGoldDeposits) then
                    for trans = 1, intTempTransNum do
                        igtType, igtName, igamount, igyears, igmonths, igdays, ighours = GetGuildBankMoneyTransaction(trans);
                        if igtType ~= "depositSummary" then
                            local tmpRealmName = strfind(igtName, "-")
                            if tmpRealmName == nil then
                                logGMessage = "G;" .. igtName .. ";" .. realmName .. ";" .. igtType .. ";" .. igamount
                            else
                                local tmpPlayerName = strsub(igtName, 1, strfind(igtName, "-") - 1)
                                local tmpRealmName = strsub(igtName, strfind(igtName, "-") + 1, #igtName)
                                logGMessage = "G;" .. tmpPlayerName .. ";" .. tmpRealmName .. ";" .. igtType .. ";" .. igamount
                            end
                            if indGoldDeposits[trans] ~= logGMessage then bolConsistency = false end
                        end
                    end
                    if not bolConsistency then errorPrint("Logs are not consistent! Please wipe and resync.") end
                elseif intTempTransNum < #(indGoldDeposits) then
                    for trans = 1, intTempTransNum do
                        igtType, igtName, igamount, igyears, igmonths, igdays, ighours = GetGuildBankMoneyTransaction(trans);
                        if igtType ~= "depositSummary" then
                            local tmpRealmName = strfind(igtName, "-")
                            if tmpRealmName == nil then
                                logGMessage = "G;" .. igtName .. ";" .. realmName .. ";" .. igtType .. ";" .. igamount
                            else
                                local tmpPlayerName = strsub(igtName, 1, strfind(igtName, "-") - 1)
                                local tmpRealmName = strsub(igtName, strfind(igtName, "-") + 1, #igtName)
                                logGMessage = "G;" .. tmpPlayerName .. ";" .. tmpRealmName .. ";" .. igtType .. ";" .. igamount
                            end
                            if indGoldDeposits[#(indGoldDeposits) - (25 - trans)] ~= logGMessage then bolConsistency = false end
                        end
                    end
                    if not bolConsistency then errorPrint("Logs are not consistent! Please wipe and resync.") end
                end
            end
            if bolUpdateWithdrawMoney and bolConsistency then
                tab = 1
                local maxTabTrans = GetNumGuildBankTransactions(tab);
                for trans = 1,maxTabTrans do
                    imtType, imtName, imitemLink, imcount, imtab1, imtab2, imyear, immonth, imday, imhour = GetGuildBankTransaction(tab, 25);
                    logMMessage = "M;" .. imtName .. ";" .. imtType .. ";" .. imcount .. ";" .. imitemLink
                end
                local maxMoneyTrans = GetNumGuildBankMoneyTransactions();
                igtType, igtName, igamount, igyears, igmonths, igdays, ighours = GetGuildBankMoneyTransaction(maxMoneyTrans);
                if igtType ~= "depositSummary" then
                    logGMessage = "G;" .. igtName .. ";" .. realmName .. ";" .. igtType .. ";" .. igamount
                    tinsert(indGoldDeposits, logGMessage)
                    tinsert(indGoldDepositsDate, igtType ..";" .. igtName ..";" .. igamount ..";" .. igyears ..";" .. igmonths ..";" .. igdays ..";" .. ighours .. ";" .. date())
                end
                bolUpdateWithdrawMoney = false;
                bolUpdateMoney = false;
            end
            updateCount = 0;
        end
    end
end

guildBankFrame:SetScript("OnEvent", guildBankFrame_OnEvent );

function infoPrint(msg, header)
    if header then print("|cffFF5500Indulgence Guild Helper\n") end
    print(msg)
end

function errorPrint(msg, header)
    if header then print("|cffFF5500Indulgence Guild Helper\n") end
    print("|cffFF5500Indulgence Guild Helper\n|cffFF0000" .. msg)
end
