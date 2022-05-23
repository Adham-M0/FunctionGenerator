disp("**************Function Generator**************");

prompt = '------Enter sampling frequency: ';
sample_freq = input(prompt);

while sample_freq <= 0
     disp("Invalid input please try again....");
     prompt = "Enter sampling frequency: ";
     sample_freq = input(prompt);
end

prompt = '------Enter start time: ';
start_time = input(prompt);

prompt = '------Enter end time: ';
end_time = input(prompt);

prompt = '------Enter the number of break points : ';
bp_number = input(prompt);

while is_not_valid_bpnum( bp_number)
    disp("Invalid input please try again....");
    bp_number = input(sprintf("------Enter the number of break points :"));
end


breakpoints_times = start_time * ones(1, bp_number);
t_last = start_time;

for i = 1: bp_number
    
    t_bp_time = input(sprintf('Break point #%d time: ', i));
    t_bp_time = allign_to_sample_point(t_bp_time, sample_freq);
   
    while is_not_valid_pbtime(t_bp_time, t_last, end_time)
        disp("Invalid input please try again....");
        t_bp_time = input(sprintf('Break point #%d time: ', i));
        t_bp_time = allign_to_sample_point(t_bp_time, sample_freq);
    end
    breakpoints_times(i) = t_bp_time;
    t_last = t_bp_time;
end
time_points = [ start_time      breakpoints_times     end_time];

lin_spaces = cell(1,length(time_points)-1) ;                                                              
function_points = cell(1,length(time_points)-1) ;  

for j = 1 : length(time_points)-1
    t_start = time_points(j);
    t_end = time_points(j+1);
    lin_spaces{j} = linspace(t_start , t_end, ( t_end - t_start ) * sample_freq);

    fprintf("Choose a definition rule for region #%d \n", j );
    disp("(1) DC Signal. ");
    disp("(2) Ramp Signal. ");
    disp("(3) GOP Signal. ");
    disp("(4) Exponential Signal. ");
    disp("(5) Sinusoidal Signal. ");
 
    prompt = '------Choose from 1 to 5 : ';
    t_select = input(prompt);
    
     switch t_select
        case 1
            t_A = input(sprintf('DC Signal Amplitude:'));
            function_points{j} = t_A + 0 * lin_spaces{j};
        case 2
            t_M = input(sprintf('Ramp Signal Slope:'));
            t_B = input(sprintf('Ramp Signal Intercept: '));
            function_points{j} = t_M * lin_spaces{j} + t_B;
        case 3
            t_O = input(sprintf('GOP Signal Order:'));
            while t_O < 1 || t_O ~= round(t_O)
                fprintf("*** Invalid Input ***");
                t_O = input(sprintf('GOP Signal Order:'));
            end
            function_points{j} = zeros(1, length(lin_spaces{j}));
            for k = t_O:-1:1
                t_A = input(sprintf('t^%d Amplitude:', k));
                function_points{j} = function_points{j} + t_A * lin_spaces{j} .^ k ;
            end
            t_B = input(sprintf('GOP Signal Intercept:'));
            function_points{j} = function_points{j} + t_B;
        case 4
            t_A = input(sprintf('Exponential Signal Amplitude:'));
            t_E = input(sprintf('Exponential Signal Exponent:'));
            function_points{j} = t_A * exp( t_E * lin_spaces{j});
        case 5
            t_A = input(sprintf('Sinusoidal Signal Amplitude:'));
            t_F = input(sprintf('Sinusoidal Signal Frequency:'));
            while t_F <=0
                fprintf("*** Invalid Input ***");
                t_F = input(sprintf('Sinusoidal Signal Frequency:'));
            end
            t_P = input(sprintf('Sinusoidal Signal Phase:'));
            function_points{j} = t_A * sin( 2 * pi * t_F * lin_spaces{j} + t_P);
    end
end

t = [ ];
for j = 1 : length(lin_spaces)
    t = [ t lin_spaces{j}(1:end) ];
end
 t = [ t lin_spaces{end}(end) ];
 
x = [ ];
for j = 1 : length(function_points)
    x = [ x function_points{j}(1:end) ];
end
x = [ x function_points{end}(end) ];

figure;
plot(t, x);

flag = 1;                                                   
while flag ~= 0
    fprintf("\n**********Signal Operations**********\n");
    fprintf("\nChoose a  signal operation to be performed: \n");
    disp("(1) Amplitude Scaling.");
    disp("(2) Time Reversal. ");
    disp("(3) Time shift. ");
    disp("(4) Expanding the signal. ");
    disp("(5) Compressing the signal.");
    disp("(6) None.");
    prompt = '------Choose from 1 to 6 : ';
    t_select = input(prompt);

    switch t_select
        case 1
            t_S = input(sprintf('Scale Value:\t'));
            x = t_S * x;
        case 2
            t = -t;
        case 3
            t_SH = input(sprintf('Shift Value X[ t - T ]:\t'));
            t = t + t_SH ;
        case 4
            t_E = input(sprintf('Expanding Value ]0 , 1[ :\t'));
            while t_E <=0 || t_E >=1
                fprintf("\t*** Invalid Input ***\t\n");
                t_E = input(sprintf('Expanding Value ]0 , 1[ :\t'));
            end
            t = t / t_E ;
        case 5
            t_C = input(sprintf('Compressing Value ]1 , inf[ :\t'));
            while t_C <=1
                fprintf("\t*** Invalid Input ***\t\n");
                t_C = input(sprintf('Compressing Value ]1 , inf[ :\t'));
            end
            t = t / t_C ;
        case 6
            flag = 0;
    end

    if flag == 1
        figure;
        plot(t, x);
        
    end
end


%%functions
function y = is_not_valid_bpnum(bpnum)
    y =  bpnum < 0 || round(bpnum) ~= bpnum;                                                                                          
end

function y = allign_to_sample_point(pbtime, sf)
     y = pbtime;
    if pbtime * sf ~= round(pbtime * sf)
        y = ceil(pbtime * sf) / sf;
    end
end

function y = is_not_valid_pbtime( pbtime, prev_time, end_)             
y =  pbtime <= prev_time || pbtime >= end_;
end