package br.com.capes.video;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.text.MessageFormat;

import org.apache.log4j.Logger;
import org.dspace.core.ConfigurationManager;

/**
 * Utils to help with video conversion and other things. Its necessary install
 * the following dependency: 
 * ffmpeg - the library itself 
 * libfaad-dev - library for audio and video development. 
 * libfaac-dev - library for audio streaming otimization. 
 * libfaad2-dev - second version of library for audio and video development.
 *
 */
public class VideoUtils {

    /**
     * log4j logger
     */
    private static Logger log = Logger.getLogger(VideoUtils.class);

    public static final String LOG_DEBUG = "debug";
    public static final String LOG_ERROR = "error";
    public static final String LOG_INFO = "info";

    /**
     * The default second of the video when the frame will be take to generate
     * the thumbnail.
     */
    public static final String THUMBNAIL_SECOND = "-10";

    /**
     * Thumbnail extension.
     */
    public static final String THUMBNAIL_EXTENSION = ".jpg";

    /**
     * Thumbnail directory.
     */
    public static final String THUMBNAIL_DIR = "thumbs";

    
    /**
     * MP4 Format
     */
    public static final String MP4_FORMAT = "mp4";
    
    /**
     * OGG Format
     */
    public static final String OGG_FORMAT = "ogg";
    
    /**
     * WEBM Format
     */
    public static final String WEBM_FORMAT = "webm";
    /**
     * Subtitle extension
     */
    public static final String SUBTITLE_FORMAT = "srt";
    /**
     * Transcription extension
     */
    public static final String TRANSCRIPTION_FORMAT = "txt";
    /**
     * Transcription extension
     */
    public static final String AUDIODESCRIPTION_FORMAT = "mp3";

    /**
     * Command to generate a image from the video. 
     * {0} = Full file path (video in). 
     * {1} = Full file path (image out). 
     * -itsoffset the second when the image will be taken 
     * -vframes the video frame for the second above 
     * -s size of the image. Use only even values.
     */
    private static final String COMMAND_CROP_VIDEO_IMAGEM_MEDIA = "ffmpeg  -itsoffset {0}  -i  {1}  -vcodec mjpeg -vframes 1 -an -f rawvideo -s 470x320 -y {2}";

    /**
     * This method generates the thumbnail.
     *
     * @param fileName full file name
     * @param thumbnailName full thumbnail name
     * @param second exact second when the frame will be taken and used to
     * generate the thumbnail
     *
     */
    private static void generateThumbnail(String fileName, String thumbnailName) {

        try {

            String commandCropImagemMedia = commandImagemMedia(fileName, thumbnailName);
            VideoUtils.executeCommand(commandCropImagemMedia);

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    /**
     * Generate the crop command to create the thumbnail using the parameters.
     *
     * @param videoOut video path
     * @return formated command to crop the image midia
     */
    private static String commandImagemMedia(String nomeArquivo, String nomeThumbnail) {
        //IMPORTANT the " caracter is needed if dspace is running on windows
        //String commandImagemMedia = new MessageFormat(COMMAND_CROP_VIDEO_IMAGEM_MEDIA).format(new Object[] {THUMBNAIL_SECOND,"\"" +  nomeArquivo + "\"", "\"" + nomeThumbnail + "\""});

        String thumbnailCropSecond = ConfigurationManager.getProperty("thumnail.crop.second") == null ? THUMBNAIL_SECOND : "-" + ConfigurationManager.getProperty("thumnail.crop.second");

        String commandImagemMedia = new MessageFormat(COMMAND_CROP_VIDEO_IMAGEM_MEDIA).format(new Object[]{thumbnailCropSecond, nomeArquivo, nomeThumbnail});

        return commandImagemMedia;
    }

    private static int executeCommand(String command) {
        Process process = null;
        Integer code = null;

        try {
            log.debug("Checking the current user \"whoami\" ");
            process = Runtime.getRuntime().exec("whoami");
            readInputStream(process.getInputStream(), LOG_DEBUG);
            log.debug("Executing command: " + command);
            process = Runtime.getRuntime().exec(command);
            readInputStream(process.getErrorStream(), LOG_DEBUG);
            code = process.waitFor();

        } catch (Throwable t) {
            t.printStackTrace();
            log.error("Error executing command: " + command, t);
        }

        if (code != 0) {
            try {

                log.error("Error code [" + code + "]: " + command);
                readInputStream(process.getErrorStream(), LOG_ERROR);

            } catch (Exception e) {
                // nothing to do
            }
        } else {
            log.debug("Command was successfully executed!");
        }

        return code;
    }

    /**
     * Returns the extension of the file without the period (.)
     *
     * @param fileName
     * @return String
     */
    public static String getVideoExtension(String fileName) {
        return fileName.substring(fileName.lastIndexOf(".") + 1);
    }

    private static void readInputStream(InputStream stderr, String logLevel) throws IOException {

        InputStreamReader isr = new InputStreamReader(stderr);
        BufferedReader br = new BufferedReader(isr);
        String line = null;
        while ((line = br.readLine()) != null) {

            if (logLevel.equals(LOG_DEBUG)) {
                log.debug(line);
            } else if (logLevel.equals(LOG_ERROR)) {
                log.error(line);
                System.out.println(line);
            } else if (logLevel.equals(LOG_INFO)) {
                log.info(line);
            }

        }

    }

    /**
     * Generates the thumnail using the id of the bitstream.
     *
     * @param handle Item handle
     * @param bitstreamSequenceID
     * @return {@link String}
     *
     */
    public static String generateThumbnailName(String handle, int bitstreamSequenceID) {
        return "thumb." + handle.replaceAll("/", "_") + bitstreamSequenceID + THUMBNAIL_EXTENSION;
    }

    /**
     * Create a new thumbnail for the flv video in the assetstore/thumbs dir.
     *
     * @param fullPathFileName The video file name (with path)
     * @param handle The item handle
     * @param bitstreamSequenceID The unique id of the bitstream
     *
     * @return String - thumbnail name
     *
     */
    public static String createThumbnail(String fullPathFileName, String handle, int bitstreamSequenceID) {

        log.debug("Creating thumbnail for " + fullPathFileName);
        String thumbnailRepository = ConfigurationManager.getProperty("upload.temp.dir");

        String fullThumbnailName = thumbnailRepository + File.separatorChar + generateThumbnailName(handle, bitstreamSequenceID);
        VideoUtils.generateThumbnail(fullPathFileName, fullThumbnailName);
        log.debug("Thumbnail " + fullThumbnailName + " created.");

        return fullThumbnailName;

    }

    /**
     * Check if the bitstream can be displayed in the video player. Case
     * bitstreamname equals null, false is returned.
     *
     * @param bitstreamName
     * @return boolean bitstream is displayable or not?
     *
     */
    public static boolean isBitstreamDisplayable(String bitstreamName) {
        if (bitstreamName != null) {
            if (VideoUtils.getVideoExtension(bitstreamName).equalsIgnoreCase(VideoUtils.MP4_FORMAT)
                    || VideoUtils.getVideoExtension(bitstreamName).equalsIgnoreCase(VideoUtils.OGG_FORMAT)
                    || VideoUtils.getVideoExtension(bitstreamName).equalsIgnoreCase(VideoUtils.WEBM_FORMAT)) {
                return true;
            }
        }

        return false;
    }

}
