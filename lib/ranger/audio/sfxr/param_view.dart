part of ranger;

abstract class ParamView {
  // Wave shape/type
  int waveShape;

  // Envelope
  double attack;  // Attack time (secconds)
  double sustain; // Sustain time (secconds)
  double punch;   // Sustain punch (proportion)
  double decay;   // Decay time (seconds)

  int sampleRate; // Hz
  int sampleSize; // bits per channel
  
  void setToDefault();

  void setForRepeat(Generator sg) {
    // Envelope
    sg.envelopeLength = [
      (attack * attack * 100000.0).floor(),
      (sustain * sustain * 100000.0).floor(),
      (decay * decay * 100000.0).floor()
    ];
    sg.envelopePunch = punch;
  }
}
