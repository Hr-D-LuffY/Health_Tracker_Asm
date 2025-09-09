.model small
.stack 100h
.data

; ---------------- DATA SECTION ---------------- 


; Variable for Feature 1: Steps Counter & Goal

step_goal dw 1000                              ; Daily step goal (default: 10,000 steps)
current_steps dw 0                              ; Current steps taken today
msg_set_step_goal db 13,10,"SET DAILY STEP GOAL (1000-9999): $"
msg_current_steps_input db 13,10,"ENTER TODAY'S STEPS TAKEN: $"
msg_goal_display db 13,10,"DAILY STEP GOAL: $"
msg_steps_display db 13,10,"CURRENT STEPS: $"
msg_remaining_steps db 13,10,"REMAINING TO REACH GOAL: $"
msg_goal_reached db 13,10,"CONGRATULATIONS! STEP GOAL REACHED! KEEP MOVING!$"
msg_goal_exceeded db 13,10,"AMAZING! YOU EXCEEDED YOUR STEP GOAL!$"
msg_progress_display db 13,10,"PROGRESS: $"
msg_percent db " %$"
msg_steps db " STEPS$"
msg_slash db " / $"
msg_div_error db 13,10,"ERROR: Division by zero or overflow. Returning to menu.$"


; Variables for Feature 2: Imperial BMI Calculator

msg_weight db 13,10,"ENTER WEIGHT (in POUNDS, 3 DIGITS MAX): $"
msg_height db 13,10,"ENTER HEIGHT (in INCHES): $"
bmi_imperial db 0
weight dw ?
height db ?


; Variables for Feature 3: Calories Burned per Exercise Type

msg_calories db 13,10,"CALORIES BURNED: $"
exercise_menu db 13,10,"SELECT EXERCISE - 1=RUN  2=WALK  3=JUMP: $"
duration_prompt db 13,10,"ENTER DURATION (IN MINUTES): $"
msg_invalid_exercise db 13,10,"INVALID EXERCISE TYPE SELECTED.$"
duration db ?
calories_burned db 0
choice db ?


; Variables for Feature 4: Body Fat Percentage Calculator

msg_bmi db 13,10,"YOUR BMI IS: $"
msg_body_fat db 13,10,"YOUR BODY FAT PERCENTAGE IS: $"
msg_age db 13,10,"ENTER AGE (in YEARS): $"  ; Added message for age input
msg_gender db 13,10,"ENTER GENDER (1=MALE, 2=FEMALE): $"  ; Added message for gender input
body_fat db 0
age db ?
gender db ? 
bmi db ?  
percent_sign db " %$"


; Variables for Feature 5: Hydration Reminder & Tracker

msg_water_input db 13,10,"ENTER NUMBER OF GLASSES OF WATER TODAY: $"
hydration db 0          ; Number of glasses of water consumed
msg_water_low db 13,10,"DRINK MORE WATER!$"
msg_water_good db 13,10,"GOOD HYDRATION LEVEL.$"


; Variables for Feature 6: Sleep Duration Tracker

msg_sleep_input db 13,10,"ENTER AVERAGE HOURS OF SLEEP (1-9): $"
sleep_avg db ?          ; Average sleep duration in hours
msg_sleep_low db 13,10,"YOU NEED MORE SLEEP.$"
msg_sleep_good db 13,10,"SLEEP DURATION IS OPTIMAL.$"
msg_sleep_high db 13,10,"TOO MUCH SLEEP.$"


; Main Menu Section

menu db 13,10,"========== HEALTH & FITNESS TRACKER =========="
     db 13,10,"1. STEPS COUNTER & GOAL TRACKER"
     db 13,10,"2. IMPERIAL BMI CALCULATOR"
     db 13,10,"3. CALORIES BURNED PER EXERCISE TYPE"
     db 13,10,"4. BODY FAT PERCENTAGE CALCULATOR"
     db 13,10,"5. HYDRATION REMINDER & TRACKER"
     db 13,10,"6. SLEEP DURATION TRACKER & ANALYSIS"
     db 13,10,"ENTER CHOICE (1-6): $"


; Start of Main Code

.code
main:
    ; Set up interrupt handler for division error
    push ds
    xor ax, ax
    mov ds, ax
    mov ax, offset div_error_handler
    mov [0], ax
    mov ax, cs
    mov [2], ax
    pop ds

    mov ax, @data
    mov ds, ax

menu_loop:
    lea dx, menu
    call print_msg
    call get_single_digit_input
    cmp al, 1         
    je steps_counter_tracker
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

; Interrupt handler for division error
div_error_handler:
    lea dx, msg_div_error
    mov ah, 9
    int 21h
    jmp menu_loop


; Feature 1 START: Steps Counter & Goal Tracker    

steps_counter_tracker:
    ; Display current step goal
    lea dx, msg_goal_display
    call print_msg
    mov ax, step_goal
    call print_number
    lea dx, msg_steps
    call print_msg
    
    ; Ask if user wants to set a new goal
    lea dx, msg_set_step_goal
    call print_msg
    call get_four_digit_input
    
    ; Validate goal input (1000-9999)
    cmp ax, 1000
    jb skip_goal_update
    cmp ax, 9999
    ja skip_goal_update
    
    ; Update goal
    mov step_goal, ax
    
    ; Display updated goal
    lea dx, msg_goal_display
    call print_msg
    mov ax, step_goal
    call print_number
    lea dx, msg_steps
    call print_msg
    
skip_goal_update:
    ; Ask for current steps
    lea dx, msg_current_steps_input
    call print_msg
    call get_four_digit_input
    mov current_steps, ax
    
    ; Display current steps
    lea dx, msg_steps_display
    call print_msg
    mov ax, current_steps
    call print_number
    lea dx, msg_slash
    call print_msg
    mov ax, step_goal
    call print_number
    lea dx, msg_steps
    call print_msg
    
    ; Calculate and display progress percentage
    lea dx, msg_progress_display
    call print_msg
    
    ; Check if step_goal is zero to avoid division by zero
    mov ax, step_goal
    cmp ax, 0
    je skip_percentage      ; Skip percentage calculation if goal is 0
    
    ; Calculate percentage: (current_steps * 100) / step_goal
    mov ax, current_steps
    mov bx, 100
    mul bx                  ; DX:AX = current_steps * 100
    mov bx, step_goal
    div bx                  ; AX = percentage (DX:AX / BX)
    call print_number
    lea dx, msg_percent
    call print_msg
    jmp check_goal_status
    
skip_percentage:
    ; Display 0% if goal is 0
    mov ax, 0
    call print_number
    lea dx, msg_percent
    call print_msg
    
check_goal_status:
    ; Check goal status and provide feedback
    mov ax, current_steps
    cmp ax, step_goal
    ja goal_exceeded        ; If steps > goal
    je goal_reached         ; If steps = goal
    
    ; Goal not reached - show remaining
    lea dx, msg_remaining_steps
    call print_msg
    mov ax, step_goal
    sub ax, current_steps
    call print_number
    lea dx, msg_steps
    call print_msg
    jmp menu_loop
    
goal_reached:
    lea dx, msg_goal_reached
    call print_msg
    jmp menu_loop
    
goal_exceeded:
    lea dx, msg_goal_exceeded
    call print_msg
    jmp menu_loop


; Feature 1 END                                     





; Feature 2: Imperial BMI Calculator

imperial_bmi_calculator:
    ; Ask for weight (in pounds)
    lea dx, msg_weight
    call print_msg
    call get_three_digit_input  ; Get 3-digit input for weight
    mov weight, ax             ; Store the 16-bit weight in AX
    
    ; Ask for height (in inches)
    lea dx, msg_height
    call print_msg
    call get_two_digit_input
    mov height, al
    
    ; Calculate BMI using the imperial formula: BMI = (weight * 703) / height^2
    
    ; Step 1: Square height (height^2)
    mov al, height
    mov ah, 0       ; Clear AH for proper multiplication
    mul al          ; AX = height * height (height^2)
    mov si, ax      ; Store height^2 in SI
    
    ; Step 2: Calculate weight * 703 using 32-bit arithmetic
    mov ax, weight  ; AX = weight (176)
    mov bx, 703     ; BX = 703
    mul bx          ; DX:AX = weight * 703 (32-bit result)
    
    ; Step 3: Divide DX:AX by height^2 (SI)
    xor dx, dx              ; Clear DX before division
    div si          ; AX = (weight * 703) / height^2, remainder in DX
    
    ; AX now contains the BMI value (floored due to integer division)
    mov bmi_imperial, al    ; Store BMI result

    ; Display BMI
    lea dx, msg_bmi
    call print_msg
    mov al, bmi_imperial
    mov ah, 0               ; Clear AH for proper display
    call print_number
    jmp menu_loop

; End of Feature 2: Imperial BMI Calculator



; Feature 3 START: Calories Burned Per Exercise    

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
 ; Feature 3 END                                    




; Feature 4: Body Fat Percentage Calculator (FIXED)

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
    xor dx, dx              ; Clear DX before division
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
    xor dx, dx              ; Clear DX before division
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


; End of Feature 4: Body Fat Percentage Calculator



;=== Feature 5 START: Hydration Reminder & Tracker    ===

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

; Feature 5 END                                   



; Feature 6 START: Sleep Duration Tracker          

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

;=== Feature 6 END                                     



; Utility Procedures START

; Prints unsigned number in AX (no leading zeros)
print_number:
    push ax
    push bx
    push cx
    push dx
    mov bx, 10
    xor cx, cx
    test ax, ax
    jnz pn_convert
    mov dl, '0'
    mov ah, 2
    int 21h
    jmp pn_done
pn_convert:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz pn_convert
pn_print:
    pop dx
    add dl, '0'
    mov ah, 2
    int 21h
    loop pn_print
pn_done:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

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
    mov ah, 01h         
    int 21h              
    sub al, '0'          
    mov bl, al           
    
    mov ah, 01h
    int 21h
    sub al, '0'          
    mov bh, al           

    mov ah, 01h
        int 21h
    sub al, '0'
    mov cl, al           

    mov al, bl
    mov ah, 0           
    mov si, 100          
    mul si              
    mov di, ax          
    
    mov al, bh           
    mov ah, 0          
    mov si, 10           
    mul si               
    add di, ax          
    
    mov al, cl           
    mov ah, 0          
    add ax, di           
    
    ret
get_three_digit_input ENDP

; Procedure to get a four-digit input (0..9999)
get_four_digit_input PROC NEAR
    mov ah, 01h
    int 21h
    sub al, '0'
    mov bl, al          ; First digit
    
    mov ah, 01h
    int 21h
    sub al, '0'
    mov bh, al          ; Second digit
    
    mov ah, 01h
    int 21h
    sub al, '0'
    mov cl, al          ; Third digit
    
    mov ah, 01h
    int 21h
    sub al, '0'
    mov ch, al          ; Fourth digit
    
    ; Calculate: (first * 1000) + (second * 100) + (third * 10) + fourth
    mov al, bl
    mov ah, 0
    mov si, 1000
    mul si              ; AX = first digit * 1000
    mov di, ax          ; Store in DI
    
    mov al, bh
    mov ah, 0
    mov si, 100
    mul si              ; AX = second digit * 100
    add di, ax          ; Add to result
    
    mov al, cl
    mov ah, 0
    mov si, 10
    mul si              ; AX = third digit * 10
    add di, ax          ; Add to result
    
    mov al, ch
    mov ah, 0           ; AX = fourth digit
    add ax, di          ; Final result in AX
    
    ret
get_four_digit_input ENDP



; Utility Procedures END

end main
