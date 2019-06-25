--[[

MIT License

Copyright (c) 2019 Mitchell Davis <coding.jackalope@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--]]

local Cursor = require(SLAB_PATH .. '.Internal.Core.Cursor')
local DrawCommands = require(SLAB_PATH .. '.Internal.Core.DrawCommands')
local Window = require(SLAB_PATH .. '.Internal.UI.Window')

local Shape = {}
local Curve = nil

function Shape.Rectangle(Options)
	Options = Options == nil and {} or Options
	Options.Mode = Options.Mode == nil and 'fill' or Options.Mode
	Options.W = Options.W == nil and 32 or Options.W
	Options.H = Options.H == nil and 32 or Options.H
	Options.Color = Options.Color == nil and nil or Options.Color
	Options.Rounding = Options.Rounding == nil and 2.0 or Options.Rounding
	Options.Outline = Options.Outline == nil and false or Options.Outline
	Options.OutlineColor = Options.OutlineColor == nil and {0.0, 0.0, 0.0, 1.0} or Options.OutlineColor

	local X, Y = Cursor.GetPosition()

	if Options.Outline and Options.Mode == 'fill' then
		DrawCommands.Rectangle('line', X, Y, Options.W, Options.H, Options.OutlineColor, Options.Rounding)
	end

	DrawCommands.Rectangle(Options.Mode, X, Y, Options.W, Options.H, Options.Color, Options.Rounding)
	Window.AddItem(X, Y, Options.W, Options.H)
	Cursor.SetItemBounds(X, Y, Options.W, Options.H)
	Cursor.AdvanceY(Options.H)
end

function Shape.Circle(Options)
	Options = Options == nil and {} or Options
	Options.Mode = Options.Mode == nil and 'fill' or Options.Mode
	Options.Radius = Options.Radius == nil and 12.0 or Options.Radius
	Options.Color = Options.Color == nil and nil or Options.Color
	Options.Segments = Options.Segments == nil and nil or Options.Segments

	local X, Y = Cursor.GetPosition()
	local CenterX = X + Options.Radius
	local CenterY = Y + Options.Radius
	local Diameter = Options.Radius * 2.0

	DrawCommands.Circle(Options.Mode, CenterX, CenterY, Options.Radius, Options.Color, Options.Segments)
	Window.AddItem(X, Y, Diameter, Diameter)
	Cursor.SetItemBounds(X, Y, Diameter, Diameter)
	Cursor.AdvanceY(Diameter)
end

function Shape.Triangle(Options)
	Options = Options == nil and {} or Options
	Options.Mode = Options.Mode == nil and 'fill' or Options.Mode
	Options.Radius = Options.Radius == nil and 12 or Options.Radius
	Options.Rotation = Options.Rotation == nil and 0 or Options.Rotation
	Options.Color = Options.Color == nil and nil or Options.Color

	local X, Y = Cursor.GetPosition()
	local CenterX = X + Options.Radius
	local CenterY = Y + Options.Radius
	local Diameter = Options.Radius * 2.0

	DrawCommands.Triangle(Options.Mode, CenterX, CenterY, Options.Radius, Options.Rotation, Options.Color)
	Window.AddItem(X, Y, Diameter, Diameter)
	Cursor.SetItemBounds(X, Y, Diameter, Diameter)
	Cursor.AdvanceY(Diameter)
end

function Shape.Line(X2, Y2, Options)
	Options = Options == nil and {} or Options
	Options.Width = Options.Width == nil and 1.0 or Options.Width
	Options.Color = Options.Color == nil and nil or Options.Color

	local X, Y = Cursor.GetPosition()
	local W, H = math.abs(X2 - X), math.abs(Y2 - Y)
	H = math.max(H, Options.Width)

	DrawCommands.Line(X, Y, X2, Y2, Options.Width, Options.Color)
	Window.AddItem(X, Y, W, H)
	Cursor.SetItemBounds(X, Y, W, H)
	Cursor.AdvanceY(H)
end

function Shape.Curve(Points, Options)
	Options = Options == nil and {} or Options
	Options.Color = Options.Color == nil and nil or Options.Color
	Options.Depth = Options.Depth == nil and nil or Options.Depth

	local X, Y = Cursor.GetPosition()

	Curve = love.math.newBezierCurve(Points)
	Curve:translate(X, Y)

	local MinX, MinY = X, Y
	local MaxX, MaxY = 0, 0
	for I = 1, Curve:getControlPointCount(), 1 do
		local PX, PY = Curve:getControlPoint(I)
		MinX = math.min(MinX, PX)
		MinY = math.min(MinY, PY)

		MaxX = math.max(MaxX, PX)
		MaxY = math.max(MaxY, PY)
	end

	local W = MaxX - MinX
	local H = MaxY - MinY

	DrawCommands.Curve(Curve:render(Options.Depth), Options.Color)
	Window.AddItem(MinX, MinY, W, H)
	Cursor.SetItemBounds(MinX, MinY, W, H)
	Cursor.AdvanceY(H)
end

function Shape.GetCurveControlPointCount()
	if Curve ~= nil then
		return Curve:getControlPointCount()
	end

	return 0
end

function Shape.GetCurveControlPoint(Index)
	if Curve ~= nil then
		return Curve:getControlPoint(Index)
	end

	return 0, 0
end

function Shape.EvaluateCurve(Time)
	if Curve ~= nil then
		return Curve:evaluate(Time)
	end

	return 0.0, 0.0
end

return Shape
