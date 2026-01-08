local mod = RegisterMod('Fly Into Challenge Rooms', 1)
local sfx = SFXManager()
local game = Game()

function mod:onUpdate()
  local level = game:GetLevel()
  local room = level:GetCurrentRoom()
  
  if room:IsClear() then
    for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
      local door = room:GetDoor(i)
      
      if door and door.TargetRoomType == RoomType.ROOM_CHALLENGE then
        local sprite = door:GetSprite()
        local filename = sprite:GetFilename()
        
        if filename == 'gfx/grid/Door_03_AmbushRoomDoor.anm2' or filename == 'gfx/grid/Door_09_BossAmbushRoomDoor.anm2' then
          if door:IsOpen() then
            sprite:Play('Open', false) -- edge case
          else
            if sprite:IsPlaying('Close') and sprite:GetFrame() == 2 then -- sometimes frame 1 is skipped
              sfx:Play(SoundEffect.SOUND_METAL_DOOR_CLOSE)
            end
            door.State = DoorState.STATE_OPEN -- the game seems to be checking both State and CollisionClass
            door.CollisionClass = GridCollisionClass.COLLISION_PIT -- COLLISION_PIT / COLLISION_OBJECT / COLLISION_SOLID (slow)
            
            for j = 0, game:GetNumPlayers() - 1 do
              local player = game:GetPlayer(j)
              
              if player:IsFlying() and room:GetGridIndex(player.Position) == door:GetGridIndex() then
                local doTransition = false
                
                if door.Direction == Direction.LEFT then
                  if player.Position.X <= door.Position.X then
                    doTransition = true
                  end
                elseif door.Direction == Direction.UP then
                  if player.Position.Y <= door.Position.Y then
                    doTransition = true
                  end
                elseif door.Direction == Direction.RIGHT then
                  if player.Position.X >= door.Position.X then
                    doTransition = true
                  end
                elseif door.Direction == Direction.DOWN then
                  if player.Position.Y >= door.Position.Y then
                    doTransition = true
                  end
                end
                
                if doTransition then
                  level.LeaveDoor = door.Slot -- important
                  game:StartRoomTransition(door.TargetRoomIndex, door.Direction, RoomTransitionAnim.WALK, player, -1)
                  return
                end
              end
            end
          end
        end
      end
    end
  end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.onUpdate)