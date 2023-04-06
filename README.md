# Wireless Communications Final Project
## Project and Design Details
This project is an implementation of a Trellis-Coded Modulation (TCM) system. Our TCM uses a rate ⅔ convolutional encoder, where one input bit is left uncoded and the other is fed through a rate ½ convolutional encoder. 

In order to perform equalization in the receiver, a randomly generated pilot sequence of seventy three 16-QAM modulated symbols is placed after every 232 message symbols. 73 pilot symbols and 232 message symbols per packet were chosen through trial and error. The combined message with the pilot sequences is then upsampled with an oversampling factor of 10. An upsampled frequency sync preamble and an upsampled timing sync preamble are then placed at the beginning of the sequence. This step is required in order to perform synchronization in the receiver. The frequency sync preamble has a length of 400 symbols and is all ones, while the timing sync preamble has a length of 100 symbols and is a pseudo-randomly generated 16-QAM sequence. Note that the receiver knows the timing sequence and pilot sequence pattern due to PRNG seeding. Next, the upsampled sequence is convolved with a square-root raised cosine rolloff pulse. The pulse uses a rolloff factor of 0.2. In order to keep the real and imaginary parts of the signal between -1 and 1, the signal is then divided by its maximum absolute value.

The 8-PSK modulator is designed such that the parallel-paths caused by the uncoded bits are maximally separated via the set partitioning scheme described in the original TCM paper. The generator polynomials were chosen arbitrarily and the full encoder and state transition table are as follows:
![alt text](https://github.com/keshav-s/WirelessCommsFinalProject/blob/main/images/Screenshot%202023-04-06%20at%206.24.04%20PM.png?raw=true)

Only the message symbols are encoded in this way; the pilot and timing preambles are normal 8-PSK modulated sequences while the frequency preamble is still just a sequence of all ones. Additionally, our message is zero-padded by 8 symbols so that the last state transmitted is the state zero. 

On the receiver, we first perform matched filtering on the signal, then perform timing and frequency synchronization. Removing the pilot sequences from the synchronized message to perform packet-level equalization, we get a stream of received data symbols. These symbols are fed into the Viterbi soft decoder, which uses the Euclidean distance between symbols as the path and branch metrics. The backtracking of the decoder uses the fact that our final state should be the zero state, so we simply find the minimum path from the zero state moving backwards. The backtracking gives us our estimated message bits which we can then use to reconstruct our original image.

## How to Run
To run the code, you simply call "create_transmit.m" to generate a .mat file containing the data. In our case, we transmit the following image:

![alt text](https://github.com/keshav-s/WirelessCommsFinalProject/blob/main/images/shannon10200.bmp?raw=true)

You can then send it over a USRP Software Desgined Radio (this was provided in class), which will send convert the .mat file to a bitstream, send the bitsream from one radio to another. The receiver radio takes the received bitstream and stores the data in a new "receivedsignal.mat" file, and example of which has been uploaded to this repo. Calling "decode_received.m" will attempt to reconstruct our original data from the received data. Our system is able successfully transmit and decode 20520 bits with a bit error rate of around 0.005.
