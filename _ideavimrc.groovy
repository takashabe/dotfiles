import com.maddyhome.idea.vim.key.KeyParser
import com.maddyhome.idea.vim.key.Shortcut
import com.maddyhome.idea.vim.command.Command
import javax.swing.KeyStroke
import java.awt.event.KeyEvent

// gc, gf, gs, ga でそれぞれのGotoコマンド実行
parser.registerAction(KeyParser.MAPPING_NORMAL, "GotoClass", Command.OTHER_READONLY, new Shortcut("gc"))
parser.registerAction(KeyParser.MAPPING_NORMAL, "GotoFile", Command.OTHER_READONLY, new Shortcut("gf"))
parser.registerAction(KeyParser.MAPPING_NORMAL, "GotoSymbol", Command.OTHER_READONLY, new Shortcut("gs"))
parser.registerAction(KeyParser.MAPPING_NORMAL, "GotoAction", Command.OTHER_READONLY, new Shortcut("ga"))

// Ctrl+] で定義に移動。Ctrl+T で戻る
parser.registerAction(KeyParser.MAPPING_NORMAL, "GotoDeclaration", Command.OTHER_READONLY, Command.FLAG_MOT_EXCLUSIVE,
    new Shortcut(KeyStroke.getKeyStroke(KeyEvent.VK_CLOSE_BRACKET, KeyEvent.CTRL_MASK)))
parser.registerAction(KeyParser.MAPPING_NORMAL, "Back", Command.OTHER_READONLY, Command.FLAG_MOT_EXCLUSIVE,
    new Shortcut(KeyStroke.getKeyStroke(KeyEvent.VK_T, KeyEvent.CTRL_MASK)))

// セミコロンでコマンドモードに入る
parser.registerAction(KeyParser.MAPPING_NVO, "VimExEntry", Command.OTHER_READ_WRITE, new Shortcut(';'))

// J を IntelliJ の join lines にリマップ
parser.registerAction(KeyParser.MAPPING_NORMAL, "EditorJoinLines", Command.OTHER_READONLY, new Shortcut("J"))

// Ctrl-n, Ctrl-p でキーワード補完
parser.registerAction(KeyParser.MAPPING_INSERT, "HippieBackwardCompletion", Command.COMPLETION, Command.FLAG_SAVE_STROKE,
    new Shortcut(KeyStroke.getKeyStroke(KeyEvent.VK_N, KeyEvent.CTRL_MASK)))
parser.registerAction(KeyParser.MAPPING_INSERT, "HippieCompletion", Command.COMPLETION, Command.FLAG_SAVE_STROKE,
    new Shortcut(KeyStroke.getKeyStroke(KeyEvent.VK_P, KeyEvent.CTRL_MASK)))
