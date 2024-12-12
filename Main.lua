-- // Variables
local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local CurrentCamera = game:GetService("Workspace").CurrentCamera;
local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");
local ShootEvent = game:GetService("ReplicatedStorage").ShootEvent;

-- // Tables
local SilentAim = {
    Enabled = true,
    HitPart = "Head",
    
    Fov = {
        Visible = true,
        Radius = 300
    },

    Target = nil;
};

-- // Functions
local Functions = { };
do
    
    function Functions:IsAlive(Player)
        if Player.Character and not Player.Character:FindFirstChild("ForceField") and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
            return true;
        end;
        return false;
    end;
    
    function Functions:GetTarget()
        local Closest, HitBox = SilentAim.Fov.Radius, nil;
        
        for _,Player in pairs(Players:GetChildren()) do
            if Player ~= LocalPlayer and Player.Team ~= LocalPlayer.Team and Functions:IsAlive(Player) then
                local HitPart = Player.Character[SilentAim.HitPart];
                local ScreenPosition, OnScreen = CurrentCamera:WorldToViewportPoint(HitPart.Position);
                local Distance = (UserInputService:GetMouseLocation() - Vector2.new(ScreenPosition.X, ScreenPosition.Y)).Magnitude;
                if OnScreen and Distance < Closest then
                    Closest = Distance;
                    HitBox = HitPart
                end;
            end;
        end;
        
        return HitBox;
    end;
    
end;

local Fov = Drawing.new("Circle");
Fov.Thickness = 1;
Fov.Color = Color3.fromRGB(255, 255, 255);

RunService.Heartbeat:Connect(function()
    
    SilentAim.Target = nil;
    if SilentAim.Enabled then
        local Target = Functions:GetTarget();
        SilentAim.Target = Target; -- Bc HookMetaMethod Takes A Shit Call It Inside The Hook.
    end;
    
    Fov.Visible = SilentAim.Enabled and SilentAim.Fov.Visible;
    if Fov.Visible then
        Fov.Position = UserInputService:GetMouseLocation();
        Fov.Radius = SilentAim.Fov.Radius;
    end;
    
end);

-- // Hooks
do
    
    local Old__namecall; Old__namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        
        if getnamecallmethod() == "FireServer" and self == ShootEvent and SilentAim.Enabled then
            local Bullets, Gun = ...;
            
            if SilentAim.Target then
                
                for _,Bullet in next, Bullets do
                    Bullet["Cframe"] = SilentAim.Target.CFrame;
                    Bullet["Hit"] = SilentAim.Target;
                end;
                
                return Old__namecall(self, Bullets, Gun);
            end;
        end;
        
        return Old__namecall(self, ...);
    end));

end;
