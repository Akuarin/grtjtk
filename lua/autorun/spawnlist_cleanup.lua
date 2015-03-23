-- Removes outdated spawnlists
function spawnlistCleanup()
	if CLIENT then
		if file.Exists( "[gmp]propellers.txt", "../settings/spawnlist/" ) then
			file.Delete( "../settings/spawnlist/[gmp]propellers.txt" )
		end
	end
end
hook.Add( "InitPostEntity", "spawnlistCleanup", spawnlistCleanup );