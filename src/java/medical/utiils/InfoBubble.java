/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.utiils;

/**
 *
 * @author rwandell
 */
public abstract class InfoBubble {
    public static int LEFT=0;
    public static int CENTER=1;
    public static int RIGHT=2;

    public static String getBubble(String className, String id, String width, String height, String backgroundColor, String contents) {
        return getBubble(className, id, width, height, LEFT, backgroundColor, contents);
    }

    public static String getBubble(String className, String id, String width, String height, int horizontalAlignment, String backgroundColor, String contents) {
        StringBuffer sb = new StringBuffer();
        String hAlign="left";

        if(horizontalAlignment==CENTER) { hAlign="center"; }
        else if(horizontalAlignment==RIGHT) { hAlign="right"; }

        if(className == null) { className="roundrect"; }
        if(id == null) { id="infoBubble"; }
        if(width == null) { width="100%"; }
        if(height == null) { height="100%"; }

        sb.append("<v:" + className + " id=\"" + id + "\" fillcolor=\"" + backgroundColor + "\" arcsize=\".06\" strokecolor=\"" + backgroundColor + "\" strokeweight=\"0px\" style=\"border-color: transparent; background-color: " + backgroundColor + "; height: " + height + "; width: " + width + "; \">\n");
        sb.append("  <div align=\"" + hAlign + "\" style=\"overflow: none; height: " + height + "; width: " + width + "; \">\n");
        sb.append(contents + "\n");
        sb.append("  </div>\n");
        sb.append("</v:" + className + ">\n");

        return sb.toString();
    }
}

// <v:roundrect fillcolor="#3399bb" arcsize=".02" style="width: 720px; height: 435px;">