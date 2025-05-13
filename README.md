Maintaining stable environmental conditions is critical for a saltwater aquarium, as
fluctuations in parameters such as temperature, salinity, and pH can be detrimental to marine life.
Additionally, equipment failures can lead to disastrous consequences. A reliable and cost-
effective aquarium controller can automate key monitoring and control tasks, providing stability
and peace of mind to aquarium enthusiasts. While commercial microcontroller-based systems
exist, they are often expensive and lack compatibility with third-party equipment. This project
aims to develop a low-cost, open-source aquarium controller using VHDL, providing users with
a customizable and robust solution for managing their aquarium environment.
The goal of this project is to design and implement an aquarium controller using VHDL
that can monitor and control temperature, automate lighting schedules, manage automatic top-
off (ATO) functionality for maintaining water levels, and provide maintenance and feeding
modes for enhanced user control, and implement fail-safe mechanisms to prevent failures.
To do this, I implemented a structural model with a top-level design with port-mapping
and individual modules for the sensors and controllers. This allowed for simpler inputs and
separate controllers so as not to be unduly influenced by other inputs. I recognized the need for a
real-time clock, Heater controller, Lighting controller, auto-top-off controller, Feed mode, and
Maintenance mode modules. These are all then connected via our Top-level design, and we then
run this top-level design with a 1 Hz and a 100 MHz clock. The 1 Hz clock is integral for the
Real Time Clock and the second counter operations, while the 100 MHz clock runs the
components. This top-down approach allows for future feature implementation and ease of
modification, as well as error correction, since not every module has access to every input or
output.
In this report, we will first go over each module and then its test benches. Then, I will
explain the top-level structure. And finally, I will explain any issues I’ve had and still have, plus
any future development that I plan to implement.
Real Time Clock Module:
For users and timed modules to be able to access the current time, I implemented a
function Real Time Clock module with user inputs to change the time. This Real Time Clock
module operates via vectors as counters for seconds, minutes, and hours, with overflows for 59
seconds, 59 minutes, and 23 hours. The Module operates with essentially 2 states, the first of
which increments the seconds counter every rising edge of the 1 Hz clock, then minutes once we
reach 59 seconds, and hours once we reach 59 minutes. Then there is the user input module,
which allows users to change the time. To do this, the user must hold down the change time
button and then press the hour or minute button to increment each vector by one. This design
also includes rollover past 59 minutes and 23 hours to reset at 0 minutes and 0 hours. We then
pipe these inputs towards the top-level design to allow other modules to access the Real Time
Clock data.
In the RTC test bench, we test the two states, including user input. In the user input, we
also include a check for overflow in user input. We then increment the hour to 23 and the minute
to 58 (11:58 PM) to ensure proper roll over to 00:00 (midnight).
Lighting Control Module:
This module acts as a programmable timed on/off switch. It takes outputs from the RTC
module (hour_out and min_out). It then compares these inputs to the set Time on and Time off
vectors. To set these vectors, the user presses and holds either the btn_time_lights_on or
btn_time_lights_of, and then taps the btn_min or btn_hour buttons to increase the saved vectors
once the btn_time_lights is released.
In the test bench for the Lighting Control Module, we test user input by setting the light
on time to 08:30 and the off time to 16:00 to ensure proper inputs. From there, we iterate the
time before the light on time, at the light on time, between the light on and off time, at the off
time, and then again after to observe that the light output is working properly.
Temperature and Heater Control Module:
The heater control module is a user-programmable module that controls the output of a
heater while monitoring temperature to be within acceptable ranges. In this module, the set
temperature is determined by 3 vectors, one of which the user can set, and the other two are ± .5
°C from the user to have an under-temp or over-temp threshold. These temperature values are
stored in vectors for every 8 bits the temperature changes by .5 °C. When converted to decimal,
408 or (25.5C) is usually the target for most aquarists; as such, the machine defaults to this value.
The controller takes input from an ADC (DS18B20) via 1-wire communication shown
later. It then compares this value to the set value and changes the FSM state based on that
comparison. The temperature first starts in normal mode where if the temperatures is less than
the set temperature it moves to an under temp heat and turns the heating output on, if the temp is
over the maximum the machine goes to an error state and throws an error flag while setting the
heater to off permanently (until reset or user maintenance mode), or stay in the state with no
heater or error flag. In the undertemp state heater output gets set on and a counter gets checked
from the min_out output and a separate min_start there two are then verified together and then
compared to a set time in this case 5 minutes this will move the undertemp to an error state
causing the heater to turn off and an error flag this is to ensure against faults in the temperature
probe and a failed heater, otherwise the state will go back to normal once the temperature goes
within the acceptable range. In the error state, the heater is permanently set to 0, and the error is
flagged; this cannot be reset until the module is reset or a maintenance input is applied. This
maintenance input is an input from a module. I will explain the future; however, the maintenance
mode turns off the heater, resets the error flag, resets the heater counter, and then goes to the
normal state once the input is set low.
The heat control testbench first simulates the current temperature to be just below the
range to trigger the heater on, then increases it to the set temperature to trigger the heater to turn
off, and then triggers an overtemp to show an error out and the heater gets shut off. I then test to
make sure even if the temperature cools, the state never changes back to normal without user
intervention. I then test the error clearing with reset, as well as the inputs to change the
temperature vectors. We then test the maintenance mode that works correctly, and then run the
test bench to ensure the heater timeout logic works correctly.
Temperature ADC 1-wire communication simulation:
Since I do not have actual hardware or memory to test communications, I made a
simulated module to walk through what 1-wire communication looks like with the DS18B20.
Communications with this ADC go as follows: the master device sets the communication wire to
high for 500 us, then pulls it low for 500 us. It then waits for a presence signal from the ADC up
to a maximum of 100 us. From there, the master device inputs 44h – command in binary to
command the ADC to convert the current temperature and save it to the ADC memory. This step
takes a maximum of 750 ms. Then the master senses the command BEh for the ADC to be able
to read the scratch pad memory, we then latch this data to save it temporarily, and allow the heat
control module to use this value. The test bench for this module just allows us to visually see this
happening.
Auto Top Off Module:
The ATO module uses two sensors to detect water at the fill line and above a maximum
line. If the top-level sensor (S2ATO) ever reads high, we immediately trigger an error, and like
the heater control module, we set the ATO_Pump assignment permanently low until reset or
maintenance mode is asserted. If the first sensor (S1ATO) reads low, we move to a fill state
where the ATO_Pump is assigned to 1 until the S1ATO reads high, in this logic we also include
a counter based on the 1 Hz clock to ensure the pump doesn’t run dry or the sensors fail and the
tank overflows. If the S2ATO or the counter ever reaches 1 and past 120 seconds, respectively,
we move to an error state where the ATO flags an error, and the pumps are set low. The only
way to get out of this error is via a reset or the maintenance user mode.
The test bench for the ATO tests for Normal filling, pump timeout, overflow error/
S2ATO high in both situations, and reset. It also tests if filling occurs during maintenance mode
and shows the system then acts normal afterwards.
User Input mode module (Maintenance and Feed):
Maintenance mode has the most importance and takes priority as it touches on most
modules (top-level outputs, heater, and ATO). This mode acts as a simple switch in which, when
activated Heat control and ATO module move to the maintenance mode, clearing errors, as well
as the Return Pump and Skimmer to get set low to allow for user input and ease of cleaning
without the potential to break equipment.
Feed mode works similar to maintenance mode in that it can control equipment, however
this mode works via timers when the user activates feed mode The Return Pump and the
skimmer get set low and a counter is activated based on the 1 Hz clock, once the counter reaches
100 (planned 600s for real purposes) The return pump gets set high, and then at 200 the skimmer
gets turned back on (planned 14400s). These values were decreased for ease of simulation.
Top-Level Design:
Our top-level design is straightforward. All our ports from our modules are shown,
including debug “dummy” ports, to see the internal logic of various modules. These ports are
then all assigned to named signals like wires. From there, I instantiated my modules and assigned
their ports to my signals.
The test bench for the Top-Level is very similar to the individual modules' test benches,
however, it shows all these changes at the same time to ensure errors do not get propagated
across many modules. The testbench first checks whether the input works with the RTC and then
checks the input with our lighting time control and its outputs. Next, the temperature control
logic is tested. The temperature is first set low (392 = 24.5°C) to trigger the heater ON condition.
Then, the temperature is increased to the target level (408 = 25.5°C) to ensure the heater turns
off. Maintenance mode is then toggled via sw_maint to confirm that it correctly clears any heater
errors. Additionally, the btn_change_temp and direction buttons are used to verify the ability to
modify the setpoint, max, and min thresholds. A final test sets the temperature extremely low
(350 = 21.875°C) and allows the system to reach the timeout condition, confirming error
flagging due to persistent under-temperature. For the ATO system, the testbench manipulates
simulated water level sensors S1ATO and S2ATO. The test triggers normal fill conditions,
overflow (top sensor high), timeout (extended fill duration), and sensor failure (bottom sensor
stuck low). Each scenario is followed by activation of maintenance mode to confirm it clears the
error flags appropriately and returns the system to a normal state. User input modes are also
validated. Maintenance mode is asserted mid-simulation to confirm it overrides normal
behavior—turning off the heater, ATO pump, return pump, and skimmer—and that it can
successfully reset module error conditions. Then Feed mode is engaged using the Feed signal to
test that the return pump and skimmer deactivate temporarily and automatically restore after the
specified timer intervals (shortened for simulation purposes). Finally, a global system reset is
applied to verify that all modules return to their initial state, and no residual errors or states
persist post-reset. The testbench concludes after a sufficient delay to observe long-duration
behaviors like heater timeout and ATO safety triggers.
Issues and Future features:
One major challenge I encountered was managing the timing of button inputs. Since the
real-time clock (RTC) operates at 1 Hz while our compclock runs at 100 MHz, the button press
timing must align precisely with the slower RTC clock. This timing mismatch is further
complicated by the lack of button debouncing, which I plan to address in the future by designing
a dedicated debounce module. Implementing such a module would not only improve input
reliability but also allow me to standardize button handling across different clock domains.
Another significant hurdle was the complexity of I²C communication. Integrating the ADCs used
for salinity and pH measurement, based on the I²C protocol, proved to be more intricate than the
rest of the project combined. While I chose to defer this feature for now, I plan to revisit and
implement it in a future iteration. Additionally, I aim to develop a module that outputs key
system information, such as temperature, time, and errors, on 7-segment displays. Looking
ahead, I would also like to add a dosing pump controller module to automate the delivery of
chemicals using peristaltic pumps.
