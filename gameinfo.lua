local function gameinfo()
	local market = game:GetService("MarketplaceService")
	local info = {}

	local success, result = pcall(function()
		return market:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
	end)

	if success then
		info = {
			"JobId Is: " .. tostring(game.JobId),
			"PlaceId Is: " .. tostring(game.PlaceId),
			"Game Name Is: " .. tostring(result.Name),
			"Description Is: " .. tostring(result.Description),
			"Created On: " .. tostring(result.Created),
			"Last Updated: " .. tostring(result.Updated),
			"Creator Name: " .. tostring(result.Creator and result.Creator.Name),
			"Creator Type: " .. tostring(result.Creator and result.Creator.CreatorType),
			"Creator ID: " .. tostring(result.CreatorTargetId),
			"AssetTypeId: " .. tostring(result.AssetTypeId),
			"Is For Sale: " .. tostring(result.IsForSale),
			"Price In Robux: " .. tostring(result.PriceInRobux),
			"Sales: " .. tostring(result.Sales),
			"Minimum Membership Level: " .. tostring(result.MinimumMembershipLevel),
			"ProductId: " .. tostring(result.ProductId),
			"IconImageAssetId: " .. tostring(result.IconImageAssetId)
		}
	else
		info = {
			"Failed to retrieve game info.",
			"Error: " .. tostring(result)
		}
	end

	return info
end
setclipboard(table.concat(gameinfo(), "\n"))
