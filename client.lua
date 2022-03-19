--[[
******************
github.com/neordev
******************
--]]

vehShop = {}
vehShop.__index = vehShop

dxDrawText = dxDrawText
dxDrawRectangle = dxDrawRectangle
tocolor = tocolor
addEventHandler = addEventHandler
getTickCount = getTickCount

function vehShop:create()
    local instance = {}
    setmetatable(instance, vehShop)
    if instance:constructor() then
        return instance
    end
    return false
end

function vehShop:constructor()
    self = vehShop;

	self.screen = Vector2(guiGetScreenSize())
	self.width, self.height = 350, 150
	self.sizeX, self.sizeY = (self.screen.x-self.width)-25, (self.screen.y-self.height)-200

    self.left = 90
    self.right = 25
    self.leftX, self.rightX = (self.screen.x-self.left)-25, (self.screen.y-self.right)

    self.mw = 700
    self.mh = 30
    self.mx, self.my = (self.screen.x-self.mw)/2, (self.screen.y-self.mh)

    self.vehTable = {
        { 'Hyundai','I20', 945, 602, 200, 35000 };
        { 'Chevrolet','Corvette Z06', 270, 429, 200, 75000 };
        { 'Honda','CR500', 14, 468, 200, 4500 };
        { 'Dodge','Charger Pursuit', 965, 560, 200, 10000000 };
    }
    self.vehDetails = {
        vehiclePreviewPosition = Vector3(537.2421875, -1285.6767578125, 17.2421875);
        cVehicle = false;
        vehShopState = nil
    }
    self.colors = {
        black = tocolor( 7, 7, 7, 230 );
        white = tocolor( 188, 188, 188, 230 )
    }
    self.click = 0
    self.selectedVehicle = 1

    self.vehPed = createPed(285, 519.7216796875, -1293.923828125, 17.2421875)
    self.vehPed.frozen = true
    
    addEventHandler('onClientClick', root, function(...) self:Click(...) end)
    addEventHandler('onClientResourceStop', root, self.resourceStopped)
end

function vehShop:toggle()
    self = vehShop;
    self.selectedVehicle = 1
    self.cVehicle = createVehicle(self.vehTable[1][4], self.vehDetails.vehiclePreviewPosition)
    Camera.setMatrix(544.51635742188,-1272.5906982422,19.852941513062,493.87539672852,-1357.1240234375,2.8351712226868)
    addEventHandler("onClientRender", root, self.render, false, "low-1")
end

function vehShop:render()
    self = vehShop;
    dxDrawRectangle( self.sizeX, self.sizeY, self.width, self.height, self.colors.black, false )
    dxDrawRectangle( self.sizeX+15, self.sizeY+20, self.width-30, 1, self.colors.white, false )

    dxDrawRectangle( self.leftX-260, self.rightX-170, self.left, self.right, self.colors.black, false )
    dxDrawRectangle( self.leftX, self.rightX-170, self.left, self.right, self.colors.black, false )

    dxDrawText( '<<', self.leftX-232, self.rightX-200, self.leftX, self.rightX-113, self.colors.white, 0.55, 'bankgothic', 'left', 'center' )
    dxDrawText( '>>', self.leftX+87, self.rightX-200, self.leftX, self.rightX-113, self.colors.white, 0.55, 'bankgothic', 'center', 'center' )

    dxDrawText( 'satın almak için "enter" tuşunu kullanabilirsiniz. çıkış yapmak için "backspace" tuşunu kullanabilirsiniz.', self.mx-100, self.my, self.mx, self.my, self.colors.white, 0.60, 'bankgothic', 'left', 'center' )

    self:Text( 'vehicle-shop', self.sizeX+self.width, self.sizeY+5, self.sizeX, self.sizeY, self.colors.white, self.colors.black, 1.75, 'pricedown', 'center', 'center' )

    if getKeyState('backspace') and self.click+800 <= getTickCount() then
        self.click = getTickCount()
        self:ClosePanel()
    end

	if self:isInBox(self.leftX-260, self.rightX-170, self.left, self.right) then
        if getKeyState('mouse1') and self.click+800 <= getTickCount() then
            self.click = getTickCount()
            if self.selectedVehicle > 0 then
                self.selectedVehicle = self.selectedVehicle - 1
                setElementModel(self.cVehicle, self.vehTable[self.selectedVehicle][4])
            end
        end
	end

	if self:isInBox(self.leftX, self.rightX-170, self.left, self.right) then
        if getKeyState('mouse1') and self.click+800 <= getTickCount() then
            self.click = getTickCount()
            if self.selectedVehicle < #self.vehTable then
                self.selectedVehicle = self.selectedVehicle + 1
                setElementModel(self.cVehicle, self.vehTable[self.selectedVehicle][4])
            end
        end
	end

    value = self.vehTable[self.selectedVehicle]

    dxDrawText( getVehicleNameFromModel(value[4]), self.sizeX+5, self.sizeY+45, self.sizeX, self.sizeY, self.colors.white, 0.65, 'bankgothic', 'left', 'top' )
    dxDrawText( value[1]..' '..value[2], self.sizeX+5, self.sizeY+65, self.sizeX, self.sizeY, self.colors.white, 0.65, 'bankgothic', 'left', 'top' )
    dxDrawText( 'max hız: '..value[5], self.sizeX+5, self.sizeY+85, self.sizeX, self.sizeY, self.colors.white, 0.65, 'bankgothic', 'left', 'top' )
    dxDrawText( 'fiyat: '..value[6]..exports['server']:getMoneyType(), self.sizeX+5, self.sizeY+105, self.sizeX, self.sizeY, self.colors.white, 0.65, 'bankgothic', 'left', 'top' )

    if getKeyState('enter') and self.click+800 <= getTickCount() then
        self.click = getTickCount()
        triggerServerEvent("carshop.buy", localPlayer, value[3], value[4], value[1], value[6])
        self:ClosePanel()
    end

end

function vehShop:Click(button, state, _, _, _, _, _, element)
    self = vehShop;
	if element then 
		if element == self.vehPed then
			if button == "right" and state == "down" then 
				if getDistanceBetweenPoints3D(self.vehPed.position, localPlayer.position) < 3 then 
					if not localPlayer.vehicle then 
						if not vehShopState then
                            vehShopState = true
                            self.toggle()
						end 
					end
				end 
			end
		end 
	end 
end

function vehShop:ClosePanel()
    self.cVehicle:destroy()
    vehShopState = nil
    setCameraTarget(localPlayer,localPlayer)
    removeEventHandler('onClientRender', root, self.render)
end

function vehShop:resourceStopped()
   setCameraTarget(localPlayer,localPlayer)
end

function vehShop:isInBox(xS,yS,wS,hS)
    if(isCursorShowing()) then
        local cursorX, cursorY = getCursorPosition()
        cursorX, cursorY = cursorX*self.screen.x, cursorY*self.screen.y
        if(cursorX >= xS and cursorX <= xS+wS and cursorY >= yS and cursorY <= yS+hS) then
            return true
        else
            return false
        end
    end
end

function vehShop:Text(text, x, y, w, h, color, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded)
	if not font then
		print("font bulunamadı: " .. text)
		return
	end

	local textWithoutColors = string.gsub(text, "#......", "")
	dxDrawText(textWithoutColors, x - 1, y - 1, w - 1, h - 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
	dxDrawText(textWithoutColors, x - 1, y + 1, w - 1, h + 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
	dxDrawText(textWithoutColors, x + 1, y - 1, w + 1, h - 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
	dxDrawText(textWithoutColors, x + 1, y + 1, w + 1, h + 1, borderColor, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
	dxDrawText(text, x, y, w, h, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, true)
end

vehShop:create()