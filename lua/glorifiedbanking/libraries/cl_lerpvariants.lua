
function LerpColor( frac, from, to )
	local col = Color(
		Lerp( frac, from.r, to.r ),
		Lerp( frac, from.g, to.g ),
		Lerp( frac, from.b, to.b ),
		Lerp( frac, from.a, to.a )
	)
	return col
end
