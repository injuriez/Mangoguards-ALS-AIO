#Requires AutoHotkey v2.0

; ------ Raids UI FindText Values ------
Raid := "|<>*130$62.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyzwzzzzUDzz7y7zzzs0zzlzVzzzy07zwTsTzzzU1zzzy7zzzswTznwVzzzyD3VAQ0M7zzXlk17041zzs0M0FU16Tzy0644MsEzzzU3XX6C41zzs0MslXVUTzyC64AMEz3zzXlU370AEzzswQ0lk30TzyTbnAzAsDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"
SurvivalShop := "|<>*133$86.00000000Q0001k07s00000TU001y07zU00006Q000Nk3Uw00001X0006A0k3U0000Mk001X0M0z7zzsyDlwzsk64TzzzzTzyTzyA1XzzzzzzszzzzX0MDlsl6TaAzD0Mk60QQA13kW7VU2A0k3730MwMlsk0X0C0lkky66AAA88k7wAQATlXXX776C1bX736A0ss1llXUMskUlVUSD0w8Mw60A0AMQDXsT0631k7U3633sq7s1UkC3yNlUNyAnr6QQ1zvzzs7xzDszzz07sDzw0yDVw3zzU00000000000000U"
RaidShop := "|<>*135$87.zzzzTyTzzrzzzzs3zzlzVzUwTzzzz07zyDwDs3Xzzzzs0TzlzVy0ATzzzz03zzzwDknXzzzzswTzvwVyDwHzzzz7XkaC0DkzU7sD4MwQ0Fk1y0w0S0M10302A0Ds1U3U3000MElXVzkAAAA8M0776AQDzlXVXl700MslXVySASAS8s7X26A8TllXlVV20wM0lk3y0ASA0M07XU6C0Ts3Xnk70ByTAnwnzVwyTVszzzzzzzzzzzzzz7zzzzzzzzzzzzzszzzzzzzzzzzzzz7zzzzzzzzzzzzzszU"
DungeonShop := "|<>*141$80.0Dzzzzzzzzzzzk0zzzzzzzzzzzw07zzzzzzzzzzz00zzzzzzzzzzzlwDzzzzzzzzzzwTUDC8zUD0y3l77s3VU7k3U70A0ly0sM0s0k1U304TUC66CAAQMMEl7s3lXVXX06D4Q1w8sMwMsk1Xl7UA666D64ATsMFs01k1XlU30C0AS01w0MwQ0s1k77W1znCTDyD0z3ntzzzzzzzXzzzzzzzzzzzwEzzzzzzzzzzzz0TzzzzzzzzzzzsTzzzzzs"
Survival := "|<>*130$96.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000003U000C0003w00000Dk000z000Dz00000As000lU00Q7U0000AM000lU00M1k0000AM000lU00k1yDzzlwTVtzlU00kXzzzztzznzzlU00lzzzzzzwTzzzlU00kTXlWAzANyS0lU00k3XVU8S4EwA0FU00M1XVUACAMQM0FU00Q1XVVwAAMMMEFU00TVXVXy4QQ8ssFk00nlXVX60QQ0sslk00llV1X30wS1sEls00k1U1X3UwT1s0kM00s3k1X1VwP3w0kM00Q7snX0nwNbiAss00DzDzz0zjtz7zzs003w7zy0D7ky1zzk00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000U"
Dungeon := "|<>*141$80.0Dzzzzzzzzzzzk0zzzzzzzzzzzw07zzzzzzzzzzz00zzzzzzzzzzzlwDzzzzzzzzzzwTUDC8zUD0y3l77s3VU7k3U70A0ly0sM0s0k1U304TUC66CAAQMMEl7s3lXVXX06D4Q1w8sMwMsk1Xl7UA666D64ATsMFs01k1XlU30C0AS01w0MwQ0s1k77W1znCTDyD0z3ntzzzzzzzXzzzzzzzzzzzwEzzzzzzzzzzzz0TzzzzzzzzzzzsTzzzzzs"

; ------ Story UI FindText Values ------
Elemental := "|<>*143$97.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzyzzzzzzzzzzzzry06Dzzzzzzzzzzzlz017zzzzzzzzlzzszU1XzzzzzzzzszzwTk0lzzzzzzzzwTzyDszszzzzzzzzw1zz7wTwT0sXXs74Q0w9Xy0SD0A00s1U60Q0lz0D7060080k1UA0MzU7XXX224QMMsy4ATlzlk1XXU0AQAT76Dszss0llk06D6DXX7wTwQTsssXz7X3kVXy0620QQQE3XlUs0kT031U6CCA0lssS0MDU1ts7bjb0twzDnDDzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz"
Challenges := "|<>*114$127.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004400000000000001sz000Dzk0000000000007zzk00Dzw000000000000DlsM00666000000000000D0AA00333000000000000C007003VVU80000US1w006003s7zkklzjzVzzzvzk0600VzDzsMPzzzxzzzzzw030yk1z0AADUC0Ds1s7UC01Uzs0S0267U303k0k1U7U1ksw070133U0U0k0M0E3k0kMC0300VVk0E0M0808Pk0QA700UUEksA0A4A0641s0C7DVsEs8MQ04D270020S031zkw8Q4AC027V3U01UD01US8S442670X3kU00ts3U0s04D20100UtVsE0EQlVk0C007VU0U080EwA0A080s03U13ks0sM608S707040w00w3Xsy4SC7UCT7z3k70w00DzzzzzzzzzzzzrVzzzy001zznwzwzzDzyTk0zzzw000000000000E00s0sy1k000000000000000S0w0000000000000000007zw0000000000000000001zw0000000000000000000Ds00000000000000000000000000000000000000000000000000000000000000000000E"
Story := "|<>*151$67.zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzsDzzzzzzzzzs3lzzzzzzzzs0szzzzzzzzwQwTzzzzzzzyDw3zzzzzzzz3w0w7WAyDzzUC0Q1k4D7zzs1UQ0M373zzz0syC4TVXzzzwQT7WDs1zzzSCDXl7y1zzz777llXz0zzzU3ks0lzkzzzs3sS0szwTzzz7zDkwzwTzzzzzzzzzyDzzzzzzzzzzDzzzzzzzzzz7zzzzzzzzzzrzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"
CloseUI(mode := "") {
    switch mode {
        case "Portals":
            return
        case "Raids":
            if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, SurvivalShop) {
                LogMessage("Accidentally Went to survival shop, Retrying!")
                BetterClick(793, 154)

            } else if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, RaidShop) {
                LogMessage("Accidentally Went to raid shop, Retrying!")
                BetterClick(793, 154)

            } else if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, DungeonShop) {
                LogMessage("Accidentally Went to dungeon shop, Retrying!")
                BetterClick(793, 154)

            } else if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, Survival) {
                LogMessage("Accidentally Went to survival, Retrying!")
                BetterClick(793, 154)

            } else if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, Dungeon) {
                LogMessage("Accidentally Went to dungeon, Retrying!")
                BetterClick(792, 152)

            } else {

            BetterClick(793, 154)
            Sleep(500)

            BetterClick(37, 393) 

            Sleep(500)
            SendInput("{WheelDown 3}")
            Sleep(1000)
            
            BetterClick(501, 418)
            Sleep(500)
            BetterClick(642, 127)
            MoveCamera()
            SendInput("{A up}")
            Sleep(100)
            SendInput("{A down}")
            Sleep(3000) 
            SendInput("{A up}")
            return
            }
        case "Dungeons":
            if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, SurvivalShop) {
                LogMessage("Accidentally Went to survival shop, Retrying!")
                BetterClick(793, 154)

            } else if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, RaidShop) {
                LogMessage("Accidentally Went to raid shop, Retrying!")
                BetterClick(793, 154)

            } else if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, DungeonShop) {
                LogMessage("Accidentally Went to dungeon shop, Retrying!")
                BetterClick(793, 154)

            } else if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, Survival) {
                LogMessage("Accidentally Went to survival, Retrying!")
                BetterClick(793, 154)

            

            } else if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, Raid) {
                LogMessage("Accidentally Went to raid, Retrying!")
                BetterClick(793, 154)
            

            } else {

            BetterClick(793, 154)
            Sleep(500)

            BetterClick(37, 393) 

            Sleep(500)
            SendInput("{WheelDown 3}")
            Sleep(1000)
            
            BetterClick(501, 418)
            Sleep(500)
            BetterClick(642, 127)
            MoveCamera()
            SendInput("{w down}")
            Sleep(1000)  ; Extended retry W movement duration to make it very visible
            SendInput("{w up}")
            Sleep(1000)
            SendInput("{a down}")
            Sleep(2938)
            SendInput("{a up}")
            return
            }
            
        case "Survival":
            if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, SurvivalShop) {
                LogMessage("Accidentally Went to survival shop, Retrying!")
                BetterClick(793, 154)

            } else if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, RaidShop) {
                LogMessage("Accidentally Went to raid shop, Retrying!")
                BetterClick(793, 154)

            } else if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, DungeonShop) {
                LogMessage("Accidentally Went to dungeon shop, Retrying!")
                BetterClick(793, 154)

            } else if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, Dungeon) {
                LogMessage("Accidentally Went to dungeon, Retrying!")
                BetterClick(792, 152)

            } else if FindText(&X, &Y, 149, 138, 591, 325, 0, 0, Raid) {
                LogMessage("Accidentally Went to raid, Retrying!")
                BetterClick(793, 154)
            
            } else {

            BetterClick(793, 154)
            Sleep(500)

            BetterClick(37, 393) 

            Sleep(500)
            SendInput("{WheelDown 3}")
            Sleep(1000)
            
            BetterClick(501, 418)
            Sleep(500)
            BetterClick(642, 127)
            MoveCamera()
            SendInput("{D up}")
            Sleep(100)
    
            SendInput("{D down}")
            Sleep(3000)  
            SendInput("{D up}")
            return
            }
        
        
        case "Legend Stages":
            if FindText(&X, &Y, 241, 192, 404, 269, 0, 0, Elemental) {
                LogMessage("Accidentally Went to Elemental Caverns, Retrying!")
                BetterClick(791, 162)
            

            } else if FindText(&X, &Y, 241, 192, 404, 269, 0, 0, Challenges) {
                LogMessage("Accidentally Went to Challenges, Retrying!")
                BetterClick(791, 162)
            
            } else {
                Sleep(500)
            
            Sleep(2000)
            
            BetterClick(40, 394)  ; Clicks teleport button
            Sleep(300)
            MouseMove(407, 297)  ; Hovers over the teleport menu
            Sleep(1000)
            BetterClick(492, 382)  ; Click on the Story & Infinity section (will need to adjust for legend stages)
            Sleep(500)
            BetterClick(642, 127)  ; Close the teleport menu
            
            MoveCamera()
            Sleep(1000)
            Sleep(500)
            
            ; Ensure key is released before pressing
            SendInput("{A up}")
            Sleep(100)
            SendInput("{A down}")
            Sleep(5000)  ; Hold A key to walk forward
            SendInput("{A up}")
                return
            }
        
        
        case "Elemental Caverns":
            if FindText(&X, &Y, 183, 202, 383, 271, 0, 0, Challenges) {
                LogMessage("Accidentally Went to Challenges, Retrying!")
                BetterClick(791, 162)
            
            } else if FindText(&X, &Y, 183, 202, 383, 271, 0, 0, Story) {
                LogMessage("Accidentally Went to Elemental Caverns, Retrying!")
                BetterClick(791, 162)
            
            } else {
                BetterClick(791, 162)
                Sleep(500)

                BetterClick(37, 393) 

                Sleep(500)
                SendInput("{WheelDown 3}")
                Sleep(1000)
                
                BetterClick(501, 418)
                Sleep(500)
                BetterClick(642, 127)
                MoveCamera()
                Sleep(1000)
                Send("{w down}")
                Sleep(1000)  
                Send("{w up}")
                Sleep(1000)
                Send("{a down}")
                Sleep(2938)
                Send("{a up}")
                return
            }
    } 
}
