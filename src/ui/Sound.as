package ui
{
  import flash.events.Event;
  import flash.media.SoundTransform;

  public class Sound
  {
    static var permamute = true;
    public static function play(index : int) : void
    {
      if (! mute && channel == null && ! permamute)
      {
        var volume = 1;
        if (index == JAM)
        {
          volume = 0.3;
        }
        channel = sounds[index].play(0, 1, new SoundTransform(volume));
        if (musicChannel != null && index == VICTORY)
        {
          channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
          musicPos = musicChannel.position;
          musicChannel.stop();
          musicChannel = null;
        }
        else
        {
          channel = null;
        }
      }
    }

    static function soundComplete(event : Event) : void
    {
      channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
      channel = null;
      if (musicChannel == null && ! mute)
      {
        musicChannel = music.play(musicPos, 1000000, new SoundTransform(1));
      }
    }

    public static function playMusic() : void
    {
      if (! mute && ! muteMusic && ! permamute)
      {
        musicChannel = music.play(0, 1000000, new SoundTransform(1));
      }
    }

    public static function toggleMute() : void
    {
      mute = ! mute;
      if (mute && musicChannel != null)
      {
        musicChannel.stop();
        musicChannel = null;
      }
      if (! mute)
      {
        playMusic();
      }
    }

    public static function toggleMusic() : void
    {
      muteMusic = ! muteMusic;
      if (muteMusic && musicChannel != null)
      {
        musicChannel.stop();
        musicChannel = null;
      }
      if (! muteMusic)
      {
        playMusic();
      }
    }

    public static function isMute() : Boolean
    {
      return mute;
    }

    public static function isMuteMusic() : Boolean
    {
      return muteMusic;
    }

    static var music = new MusicClip();
    static var musicChannel = null;
    static var musicPos = 0;
    static var mute = false;
    static var muteMusic = false;
    static var channel = null;
    static var sounds = [new CancelSound(), new JamSound(), new MixerSound(),
                         new MouseOverSound(), new PlaceSound(),
                         new SelectSound(), new SpraySound(),
                         new SuccessSound(), new VictorySound()];
    public static var CANCEL = 0;
    public static var JAM = 1;
    public static var MIXER = 2;
    public static var MOUSE_OVER = 3;
    public static var PLACE = 4;
    public static var SELECT = 5;
    public static var SPRAY = 6;
    public static var SUCCESS = 7;
    public static var VICTORY = 8;
  }
}
