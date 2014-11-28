part of ranger;

class FastBase64 {
  static const CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
  List<String> encLookup = new List<String>(4096);
  
  FastBase64();
  
  factory FastBase64.basic() {
    FastBase64 o = new FastBase64();
    
    if (o.init()) {
      return o;
    }
    
    return null;
  }


  bool init() {
    for (int i = 0; i < 4096; i++)
      encLookup[i] = CHARS[i >> 6] + CHARS[i & 0x3F];

    return true;
  }

  String encode(Uint8List src) {
    int len = src.length;
    String dst = "";
    int i = 0;
    int n;
    List<String> que = new List<String>(3);
    int q = 0;
    String enc;
    
    while (len > 2) {
      n = (src[i] << 16) | (src[i+1]<<8) | src[i+2];
      enc = encLookup[n >> 12] + encLookup[n & 0xFFF];
      dst += enc;
      
      len -= 3;
      i += 3;
    }

    // len = 3 or 2 or 1
    if (len > 0) {
      int n1= (src[i] & 0xFC) >> 2;
      int n2= (src[i] & 0x03) << 4;
      
      if (len > 1)
        n2 |= (src[i+1] & 0xF0) >> 4;
      
      dst += CHARS[n1];
      dst += CHARS[n2];
      
      if (len == 2) {
        int n3 = (src[i] & 0x0F) << 2;
        n3 |= (src[i+1] & 0xC0) >> 6;
        dst += CHARS[n3];
      }
      
      if (len == 1)
        dst += '=';
      
      dst += '=';
    }
    
    return dst;
  }
}

/**
 * https://ccrma.stanford.edu/courses/422/projects/WaveFormat/
 */
class Wave {
  // Byte offsets                           // Size  Comment
  static const int CHUNK_ID =           0;  // 4     "RIFF" = 0x52494646
  static const int CHUNK_SIZE =         4;  // 4     36+SubChunk2Size = 4+(8+SubChunk1Size)+(8+SubChunk2Size)
  static const int FORMAT =             8;  // 4     "WAVE" = 0x57415645
  static const int SUB_CHUNK_1INDEX =   12; // 4     "fmt " = 0x666d7420
  static const int SUB_CHUNK_1SIZE =    16; // 4     16 = 0x10 for PCM
  static const int AUDIO_FORMAT =       20; // 2     PCM = 0x01
  static const int NUMBER_OF_CHANNELS = 22; // 2     Mono = 0x01, Stereo = 0x02, etc.
  static const int SAMPLE_RATE =        24; // 4     8000, 44100, etc
  static const int BYTE_RATE =          28; // 4     SampleRate * NumChannels * BitsPerSample / 8
  static const int BLOCK_ALIGN =        32; // 2     NumChannels * BitsPerSample / 8
  static const int BITS_PER_SAMPLE =    34; // 2     8 bits = 0x08, 16 bits = 0x10, etc.
  static const int SUB_CHUNK_2INDEX =   36; // 4     "data" = 0x64617461
  static const int SUB_CHUNK_2SIZE =    40; // 4     data size = NumSamples * NumChannels * BitsPerSample / 8
  static const int DATA =               44; // N
  
  static const int HEADER_SIZE = 44;

  // 4 byte hex ascii strings.
  static const int S_RIFF = 0x52494646;
  static const int S_WAVE = 0x57415645;
  static const int S_fmt_ = 0x666d7420;
  static const int S_data = 0x64617461;

  /// The raw generated wave file data.
  Uint8List wav;
  
  // MIME http://en.wikipedia.org/wiki/Data_URI_scheme
  /// The MIME base64 encoded wave
  String dataURI = "";

  int subChunk1Size = 16;
  
  /// Default rate is 8000
  int sampleRate = 8000;
  /// Default to PCM = 1
  int audioFormat = 1;
  /// Default is 1 channel
  int numberOfChannels = 1;
  /// Default is 8
  int bitsPerSample = 8;
  
  /// {Informational} Simply indicates if clipping occurred and how many times.
  int clipping = 0;
  
  void create(List<int> data) {
    int wavSize = HEADER_SIZE + data.length;
    wav = new Uint8List(wavSize);
    ByteData raw = new ByteData.view(wav.buffer);

    int subChunk2Size = data.length;
    
    // Header part
    raw.setUint32(CHUNK_ID, S_RIFF);
    raw.setUint32(CHUNK_SIZE, SUB_CHUNK_2INDEX + subChunk2Size, Endianness.HOST_ENDIAN);
    raw.setUint32(FORMAT, S_WAVE);
    raw.setUint32(SUB_CHUNK_1INDEX, S_fmt_);
    raw.setUint32(SUB_CHUNK_1SIZE, subChunk1Size, Endianness.HOST_ENDIAN);
    raw.setUint16(AUDIO_FORMAT, audioFormat, Endianness.HOST_ENDIAN);
    raw.setUint16(NUMBER_OF_CHANNELS, numberOfChannels, Endianness.HOST_ENDIAN);
    raw.setUint32(SAMPLE_RATE, sampleRate, Endianness.HOST_ENDIAN);
    raw.setUint32(BYTE_RATE, (sampleRate * numberOfChannels * bitsPerSample) >> 3, Endianness.HOST_ENDIAN); // ">>3" = "~/8"
    raw.setUint16(BLOCK_ALIGN, (numberOfChannels * bitsPerSample) >> 3, Endianness.HOST_ENDIAN);
    raw.setUint16(BITS_PER_SAMPLE, bitsPerSample, Endianness.HOST_ENDIAN);
    raw.setUint32(SUB_CHUNK_2INDEX, S_data);
    raw.setUint32(SUB_CHUNK_2SIZE, subChunk2Size, Endianness.HOST_ENDIAN);
    
    // Append Data
    for(int i = DATA, j = 0; i < data.length + DATA; i++)
      raw.setUint8(i, data[j++]);
    
    FastBase64 fast = new FastBase64.basic();
    dataURI = 'data:audio/wav;base64,' + fast.encode(wav);
  }

}

