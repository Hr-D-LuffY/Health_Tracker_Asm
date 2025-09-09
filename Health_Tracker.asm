.model small
.stack 100h
.data

; ---------------- DATA SECTION ---------------- 

; ==========================
; Variable for Feature 1: Weekly Progress Tracker
; ==========================
msg_feedback_tip_1 db 13,10,"KEEP SETTING NEW GOALS AND BREAKING THEM!$"

; Data arrays for tracking progress for each day
week1 db 7 dup(?), 10, 10, 10, 10, 10, 10, 10   ; Monday to Sunday initial values (stored at +8..+14)
week2 db 7 dup(?), 15, 15, 15, 15, 15, 15, 15   ; Previous week data for comparison
goal db 50                                       ; Calories rate per exercise
goal_remaining db 30                            ; Remaining days to reach goal
prev_goal_remaining db 30                       ; Track previous day count for adjustment
msg_progress_updated db 13,10,"PROGRESS UPDATED: INCREASED BY 10$"
msg_select_day db 13,10,"SELECT DAY (1=MON, 2=TUE, 3=WED, 4=THU, 5=FRI, 6=SAT, 7=SUN): $"
msg_day_selected db 13,10,"DAY SELECTED: $"
msg_current_progress db 13,10,"CURRENT PROGRESS: $" 
msg_compare db 13,10,"PROGRESS INCREASED TODAY. KEEP IT UP!$" 
msg_decreased db 13,10,"PROGRESS DECREASED TODAY. DON'T GIVE UP!$" 
msg_invalid_day db 13,10,"INVALID DAY. PLEASE ENTER 1..7.$"

; =======================================
; Variables for Feature 2: Imperial BMI Calculator
; =======================================
msg_weight db 13,10,"ENTER WEIGHT (in POUNDS, 3 DIGITS MAX): $"
msg_height db 13,10,"ENTER HEIGHT (in INCHES): $"
bmi_imperial db 0
weight db ?
height db ?

; ==========================
; Variables for Feature 3: Calories Burned per Exercise Type
; ==========================
msg_calories db 13,10,"CALORIES BURNED: $"
exercise_menu db 13,10,"SELECT EXERCISE - 1=RUN  2=WALK  3=JUMP: $"
duration_prompt db 13,10,"ENTER DURATION (IN MINUTES): $"
msg_invalid_exercise db 13,10,"INVALID EXERCISE TYPE SELECTED.$"
duration db ?
calories_burned db 0
choice db ?

; =======================================
; Variables for Feature 4: Body Fat Percentage Calculator
; =======================================
msg_bmi db 13,10,"YOUR BMI IS: $"
msg_body_fat db 13,10,"YOUR BODY FAT PERCENTAGE IS: $"
msg_age db 13,10,"ENTER AGE (in YEARS): $"  ; Added message for age input
msg_gender db 13,10,"ENTER GENDER (1=MALE, 2=FEMALE): $"  ; Added message for gender input
body_fat db 0
age db ?
gender db ? 
bmi db ?  
percent_sign db " %$"

; ==========================
; Variables for Feature 5: Hydration Reminder & Tracker
; ==========================
msg_water_input db 13,10,"ENTER NUMBER OF GLASSES OF WATER TODAY: $"
hydration db 0          ; Number of glasses of water consumed
msg_water_low db 13,10,"DRINK MORE WATER!$"
msg_water_good db 13,10,"GOOD HYDRATION LEVEL.$"

; ==========================
; Variables for Feature 6: Sleep Duration Tracker
; ==========================
msg_sleep_input db 13,10,"ENTER AVERAGE HOURS OF SLEEP (1-9): $"
sleep_avg db ?          ; Average sleep duration in hours
msg_sleep_low db 13,10,"YOU NEED MORE SLEEP.$"
msg_sleep_good db 13,10,"SLEEP DURATION IS OPTIMAL.$"
msg_sleep_high db 13,10,"TOO MUCH SLEEP.$"

; =======================================
; Main Menu Section
; =======================================
menu db 13,10,"========== HEALTH & FITNESS TRACKER =========="
     db 13,10,"1. WEEKLY PROGRESS COMPARISON"
     db 13,10,"2. IMPERIAL BMI CALCULATOR"
     db 13,10,"3. CALORIES BURNED PER EXERCISE TYPE"
     db 13,10,"4. BODY FAT PERCENTAGE CALCULATOR"
     db 13,10,"5. HYDRATION REMINDER & TRACKER"
     db 13,10,"6. SLEEP DURATION TRACKER & ANALYSIS"
     db 13,10,"ENTER CHOICE (1-6): $"

; ================================
; Start of Main Code
; ================================
.code
main:
    mov ax, @data
    mov ds, ax

menu_loop:
    lea dx, menu
    call print_msg
    call get_single_digit_input
    cmp al, 1         
    je weekly_progress_comparison
    cmp al, 2         
    je imperial_bmi_calculator
    cmp al, 3
    je calories_burned_calc
    cmp al, 4         
    je body_fat_calculator
    cmp al, 5
    je hydration_tracker
    cmp al, 6
    je sleep_tracker

    jmp menu_loop

;========================================================
;=== Feature 1 START: Weekly Progress Comparison      ===
;========================================================
weekly_progress_comparison:
    ; Ask user to select a day
    lea dx, msg_select_day
    call print_msg
    call get_single_digit_input
    
    ; Validate day input (1-7)
    cmp al, 1
    jb invalid_day
    cmp al, 7
    ja invalid_day
    
    ; Store selected day (convert to 0-based index + 8 offset)
    mov bl, al
    add bl, 7              ; Add 7 to get to the valid data portion (index 8)
    
    ; Show which day was selected
    lea dx, msg_day_selected
    call print_msg
    mov al, bl
    sub al, 7              ; Convert back to 1-7 for display
    call print_number
    
    ; Show current progress for selected day
    lea dx, msg_current_progress
    call print_msg
    
    ; Get and display current progress value
    lea si, week1
    mov bx, 0
    mov bl, al             ; Put day number (1-7) in BL
    add bl, 7              ; Move to valid data portion
    mov al, [si+bx]
    xor ah, ah
    call print_number
    
    ; Increment progress by 10 for selected day
    lea si, week1
    add al, 10             ; Increment by 10
    mov [si+bx], al        ; Store updated value
    
    ; Display update message
    lea dx, msg_progress_updated
    call print_msg
    
    ; Display new progress value
    lea dx, msg_current_progress
    call print_msg
    xor ah, ah
    mov al, [si+bx]
    call print_number
    
    ; Compare with previous week's progress for the selected day
    lea si, week1
    lea di, week2
    mov al, [si+bx]
    cmp al, [di+bx]
    ja label_msg_up
    jb label_msg_down
    
label_msg_up:
    lea dx, msg_compare
    call print_msg
    
label_msg_down:
    lea dx, msg_decreased
    call print_msg
    


invalid_day:
    lea dx, msg_invalid_day
    call print_msg
    jmp menu_loop

;========================================================
;=== Feature 1 END                                     ===
;========================================================



; ================================
; Feature 2: Imperial BMI Calculator
; ================================
imperial_bmi_calculator:
    ; Ask for weight (in pounds)
    lea dx, msg_weight
    call print_msg
    call get_three_digit_input  ; Now calling the procedure for 3-digit input
    mov weight, al             ; Store the 8-bit weight in AL (lower byte of AX)
    
    ; Ask for height (in inches)
    lea dx, msg_height
    call print_msg
    call get_two_digit_input
    mov height, al
    
    ; Calculate BMI using the imperial formula
    ; BMI = (weight / height^2) * 703
    
    ; Step 1: Square height (height^2)
    mov al, height
    mov ah, al      ; AH = height (in inches)
    mul al          ; AX = height * height (height^2)
    
    mov si, ax      ; Store height^2 in SI
    
    ; Step 2: BMI = (weight / height^2) * 703
    ; Move weight (8-bit) into AX
    mov al, weight           ; AL = weight (8-bit value)
    
    ; Divide weight by height^2
    mov dx, 0               ; Clear DX for division (DX:AX will hold the 32-bit value)
    div si                  ; AX = weight / height^2, result in AX (BMI)
    
    ; Step 3: Multiply the result by 703
    mov bx, 703             ; Load 703 into BX
    mul bx                  ; AX = BMI * 703 (scaled)
    
    mov bmi_imperial, al  ; Store BMI result in bmi_imperial
    
    ; Display BMI
    lea dx, msg_bmi
    call print_msg
    mov al, bmi_imperial
    call print_number
    jmp menu_loop

; ================================
; End of Feature 2: Imperial BMI Calculator
; ================================

;========================================================
;=== Feature 3 START: Calories Burned Per Exercise    ===
;========================================================
calories_burned_calc:
    lea dx, exercise_menu
    call print_msg
    call get_single_digit_input  
    
    cmp al, 1
    jb invalid_exercise
    cmp al, 3
    ja invalid_exercise
   
    mov choice, al                   ; BL = 1(run)/2(walk)/3(jump)
   
    lea dx, duration_prompt
    call print_msg
    call get_two_digit_input     
    mov duration, al             
   
    mov bl,choice
    cmp bl, 1
    je set_run_rate         
    cmp bl, 2
    je set_walk_rate
    mov al, 7               ; Jumping: 7 calories per minute
    jmp perform_calculation  
   
set_run_rate:
    mov al, 10            ; Running: 10 calories per minute
    jmp perform_calculation
   
set_walk_rate:
    mov al, 5             ; Walking: 5 calories per minute
    jmp perform_calculation

perform_calculation:
    mov ah, 0           

    mov bl, duration      
    mov bh, 0          

    ; Perform multiplication (rate * duration)
    mul bx                
    
    cmp ax, 255
    jbe store_result
    mov ax, 255           ; If AX > 255, set AX to 255

store_result:
    mov calories_burned, al  

    lea dx, msg_calories
    call print_msg
   
    mov ah, 0               
    mov al, calories_burned 
    call print_number        
    jmp menu_loop         
   
invalid_exercise:
    lea dx, msg_invalid_exercise
    call print_msg
    jmp menu_loop    
    
;========================================================
;=== Feature 3 END                                     ===
;========================================================


; ================================
; Feature 4: Body Fat Percentage Calculator (FIXED)
; ================================
body_fat_calculator:
    lea dx, msg_bmi
    call print_msg
    call get_two_digit_input  
    mov bmi, al      
    
    lea dx, msg_age
    call print_msg
    call get_two_digit_input
    mov age, al
    
    lea dx, msg_gender
    call print_msg
    call get_single_digit_input
    mov gender, al
    
    ; Calculate body fat percentage based on gender
    ; For Male: body fat = (1.20 * BMI) + (0.23 * age) - 16.2
    ; For Female: body fat = (1.20 * BMI) + (0.23 * age) - 5.4
    
    cmp gender, 1
    je male_body_fat
    cmp gender, 2
    je female_body_fat
    jmp menu_loop
    
male_body_fat:
    ; Scale everything by 100 to handle decimals
    
    ; Step 1: Calculate 1.20 * BMI = 120 * BMI / 100
    mov al, bmi    
    mov ah, 0               
    mov bx, 120             
    mul bx                  
    mov cx, ax              
    
    ; Step 2: Calculate 0.23 * age = 23 * age / 100
    mov al, age             
    mov ah, 0               
    mov bx, 23              
    mul bx                  
    
    ; Step 3: Add the two terms
    add cx, ax              ; CX = (120 * BMI) + (23 * age)
    
    ; Step 4: Subtract 16.2 = 1620 (scaled by 100)
    sub cx, 1620            
    
    ; Step 5: Divide by 100 to get final result (floor operation)
    mov ax, cx              
    mov bx, 100             
    mov dx, 0               
    div bx                  
    
    mov body_fat, al        ; Store the floored result
    jmp display_body_fat

female_body_fat:
    
    ; Step 1: Calculate 1.20 * BMI = 120 * BMI / 100
    mov al, bmi    
    mov ah, 0               
    mov bx, 120             
    mul bx                  
    mov cx, ax              
    
    ; Step 2: Calculate 0.23 * age = 23 * age / 100
    mov al, age             
    mov ah, 0               
    mov bx, 23              
    mul bx                 
    
    ; Step 3: Add the two terms
    add cx, ax              ; CX = (120 * BMI) + (23 * age)
    
    ; Step 4: Subtract 5.4 = 540 (scaled by 100)
    sub cx, 540           
    
    ; Step 5: Divide by 100 to get final result (floor operation)
    mov ax, cx              
    mov bx, 100             
    mov dx, 0               
    div bx
    
    mov body_fat, al        ; Store the floored result


display_body_fat:
    lea dx, msg_body_fat
    call print_msg
    mov al, body_fat        
    mov ah, 0               
    call print_number      
    lea dx, percent_sign   
    call print_msg          
    jmp menu_loop

; ================================
; End of Feature 4: Body Fat Percentage Calculator
; ================================

;========================================================
;=== Feature 5 START: Hydration Reminder & Tracker    ===
;========================================================
hydration_tracker:
    lea dx, msg_water_input
    call print_msg
    call get_single_digit_input
    mov hydration, al
    cmp hydration, 6
    jb not_enough_water
    lea dx, msg_water_good
    call print_msg
    jmp menu_loop

not_enough_water:
    lea dx, msg_water_low
    call print_msg
    jmp menu_loop
;========================================================
;=== Feature 5 END                                     ===
;========================================================

;========================================================
;=== Feature 6 START: Sleep Duration Tracker          ===
;========================================================
sleep_tracker:
    lea dx, msg_sleep_input
    call print_msg
    call get_single_digit_input
    mov sleep_avg, al
    cmp al, 5
    jb too_little_sleep
    cmp al, 8
    ja too_much_sleep
    lea dx, msg_sleep_good
    call print_msg
    jmp menu_loop

too_little_sleep:
    lea dx, msg_sleep_low
    call print_msg
    jmp menu_loop

too_much_sleep:
    lea dx, msg_sleep_high
    call print_msg
    jmp menu_loop
;========================================================
;=== Feature 6 END                                     ===
;========================================================

; ============================
; Utility Procedures START
; ============================
; Procedure to print a number in AX (unsigned, no leading zeros)
print_number PROC NEAR
    ; Handle special case of 0
    cmp al, 0
    jne not_zero
    mov dl, '0'
    mov ah, 2
    int 21h
    ret

not_zero:
    ; For numbers 1-99, we only need to handle max 2 digits
    mov bl, al          
    
    cmp al, 10
    jb print_units     
    
    mov ah, 0           
    mov cl, 10          
    div cl              
    mov dl, al          
    add dl, '0'         
    mov ah, 2           
    int 21h             
    
    mov al, bl          
    mov ah, 0          
    mov cl, 10         
    div cl              
    mov al, ah          

print_units:
    add al, '0'        
    mov dl, al         
    mov ah, 2           
    int 21h         
    
    ret
print_number ENDP

; Procedure to print a message at DS:DX ending with '$'
print_msg PROC NEAR
    mov ah, 9
    int 21h
    ret
print_msg ENDP

; Procedure to get a single digit input from the user (0..9)
get_single_digit_input PROC NEAR
    mov ah, 1
    int 21h
    sub al, '0'
    and al, 0Fh
    ret
get_single_digit_input ENDP

; Procedure to get a two-digit input (0..99)
get_two_digit_input PROC NEAR
    mov ah, 1
    int 21h
    sub al, '0'
    mov bl, al
    mov ah, 1
    int 21h
    sub al, '0'
    mov bh, al
    mov al, bl
    mov ah, 0
    mov cl, 10
    mul cl
    add al, bh
    ret
get_two_digit_input ENDP

; Procedure to get a three-digit input (0..999)
get_three_digit_input PROC NEAR
    ; Get the first digit
    mov ah, 01h         
    int 21h              
    sub al, '0'          
    mov bl, al           

    ; Get the second digit
    mov ah, 01h
    int 21h
    sub al, '0'          
    mov bh, al          

    ; Get the third digit
    mov ah, 01h
    int 21h
    sub al, '0'          

    mov al, bl           
    mov cl, 100          
    mul cl               
    
    mov al, bh           
    mov cl, 10          
    mul cl               
    add ax, bx          
    
    add ax, ax           
    mov al, ah           
   ret
get_three_digit_input ENDP



; ============================
; Utility Procedures END
; ============================
end main
