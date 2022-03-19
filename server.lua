mysql = exports.mysql

function SmallestID()
	local query = dbQuery(mysql:getConnection(), "SELECT MIN(e1.id+1) AS nextID FROM vehicles AS e1 LEFT JOIN vehicles AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	local result = dbPoll(query, -1)
	if result then
		local id = tonumber(result[1]["nextID"]) or 1
		return id
	end
	return false
end

addEvent("carshop.buy", true)
addEventHandler("carshop.buy", root, function(libID, vehID, vehName, price)
	if source and tonumber(libID) and tonumber(vehID) then
		if exports.global:takeMoney(source, price) then

			local r, g, b = 255, 255, 255
			local dbid = source:getData('dbid')
			local x, y, z = 525.6123046875, -1285.54296875, 17.2421875
			local rotZ = 16.059509277344
			local letter1 = string.char(math.random(65,90))
			local letter2 = string.char(math.random(65,90))
			local plate = letter1 .. letter2 .. math.random(0, 9) .. " " .. math.random(1000, 9999)
			local var1, var2 = exports['vehicle']:getRandomVariant(vehID)
			local color1 = toJSON( {r,g,b} )
			local color2 = toJSON( {0, 0, 0} )
			local color3 = toJSON( {0, 0, 0} )
			local color4 = toJSON( {0, 0, 0} )
			local tint = 0
			local factionVehicle = -1
			local smallestID = SmallestID()

			local veh = createVehicle(vehID, x,y,z)
			setVehicleColor(veh, r,g,b)

			dbExec(mysql:getConnection(), "INSERT INTO vehicles SET id='"..(smallestID).."', model='" .. (vehID) .. "', x='" .. (x) .. "', y='" .. (y) .. "', z='" .. (z) .. "', rotx='0', roty='0', rotz='" .. (rotZ) .. "', color1='" .. (color1) .. "', color2='" .. (color2) .. "', color3='" .. (color3) .. "', color4='" .. (color4) .. "', faction='" .. (factionVehicle) .. "', owner='" .. (dbid) .. "', plate='" .. (plate) .. "', currx='" .. (x) .. "', curry='" .. (y) .. "', currz='" .. (z) .. "', currrx='0', currry='0', currrz='" .. (rotZ) .. "', locked='1', interior='0', currinterior='0', dimension='0', currdimension='0', tintedwindows='" .. (tint) .. "',variant1='"..var1.."',variant2='"..var2.."', creationDate=NOW(), createdBy='-1', `vehicle_shop_id`='"..libID.."' ")

			call( getResourceFromName("items"), "deleteAll", 3, smallestID)
			exports.global:giveItem(source, 3, smallestID)
			destroyElement(veh)
			exports['vehicle']:reloadVehicle(smallestID)
			exports['infobox']:addBox(source, 'info', 'Başarıyla '..vehName..' isimli aracı satın aldınız!')
			exports['infobox']:addBox(source, 'info', '/aracgetir komutunu kullanarak aracı yanınıza çekebilirsiniz!')
		else
			exports['infobox']:addBox(source, 'info', 'Bu aracı almak için '..price-source:getData('money')..'$ daha eklemeniz gerekmektedir!')
		end
	end
end)