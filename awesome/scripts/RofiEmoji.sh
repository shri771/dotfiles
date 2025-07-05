#!/bin/bash
# Rofi Emoticons. Not my own. Cant remember the source

set -euo pipefail

# Ensure dependencies are installed
check_dependencies() {
    local deps=("rofi" "wl-copy" "hyprctl" "awk" "tr")
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            printf "Error: Required command '%s' not found. Please install it.\n" "$cmd" >&2
            return 1
        fi
    done
}

# Get cursor position from Hyprland
get_cursor_position() {
    local cursorpos x y
    cursorpos=$(hyprctl cursorpos 2>/dev/null) || return 1

    if ! [[ "$cursorpos" =~ ^([0-9]+),\ ([0-9]+)$ ]]; then
        printf "Error: Invalid cursor position retrieved: '%s'\n" "$cursorpos" >&2
        return 1
    fi

    x="${BASH_REMATCH[1]}"
    y="${BASH_REMATCH[2]}"

    printf "%s %s\n" "$x" "$y"
}

# Calculate Rofi window position with proper edge gaps
calculate_rofi_position() {
    local x=$1
    local y=$2
    local screen_width=1920  # Replace with your screen width
    local screen_height=1200 # Replace with your screen height
    local rofi_width=$((screen_width * 25 / 100))  # 30% of screen width
    local rofi_height=$((screen_height * 35 / 100)) # 40% of screen height
    local edge_gap=20  # Minimum gap from edges
    local bottom_gap=45 # Additional gap when near the bottom

    # Adjust X position if near the right or left edge
    if ((x + rofi_width > screen_width - edge_gap)); then
        x=$((screen_width - rofi_width - edge_gap))
    elif ((x < edge_gap)); then
        x=$edge_gap
    fi

    # Adjust Y position if near the bottom or top edge
    if ((y + rofi_height > screen_height - edge_gap)); then
        y=$((screen_height - rofi_height - bottom_gap))
    elif ((y > screen_height - rofi_height)); then
        y=$((screen_height - rofi_height - bottom_gap))
    elif ((y < edge_gap)); then
        y=$edge_gap
    fi

    printf "%s %s\n" "$x" "$y"
}

# Display Rofi with emoji list
emoji_picker() {
    local x y selection
    read -r x y < <(get_cursor_position) || return 1
    read -r x y < <(calculate_rofi_position "$x" "$y")

    local emoji_list
    emoji_list=$(sed '1,/^# # DATA # #$/d' "$0") || return 1
    [[ -z "$emoji_list" ]] && emoji_list="No emojis available"

    printf "Launching Rofi at X:%s Y:%s\n" "$x" "$y" >&2

    selection=$(echo "$emoji_list" | rofi -i -dmenu \
        -config ~/.config/rofi/config-emoji.rasi \
        -theme-str "window { location: northwest; x-offset: ${x}px; y-offset: ${y}px; }" \
        -kb-move-up "Control+p" \
        -kb-move-down "Control+n" \
        -kb-accept-entry "Return"
    ) || return 1

    [[ "$selection" == "No emojis available" ]] && return

    echo "$selection" | awk -F'\t' '{print $1}' | tr -d '\n' | wl-copy

    # Paste the selected emoji automatically
    wtype -M ctrl v -m ctrl
}

main() {
    check_dependencies || exit 1
    emoji_picker
}

main

# # DATA # #
😀 faceface | grin | grinning face
😂 faceface | joy | face with tears of joy
😊 faceface | smile | smiling face with smiling eyes
😇 faceface | innocent | smiling face with halo
🙂 faceface | slightly_smiling_face | slightly smiling face
🙃 faceface | upside_down_face | upside-down face
😉 faceface | wink | winking face
😌 faceface | relaxed | relieved face
😍 faceface | heart_eyes | smiling face with heart-eyes
🥰 faceface | smiling_face_with_hearts | smiling face with hearts
😘 faceface | kiss | kissing face
😗 faceface | kissing_face | kissing face
😙 faceface | kissing_face_with_smiling_eyes | kissing face with smiling eyes
😚 faceface | kissing_face_with_closed_eyes | kissing face with closed eyes
😋 faceface | yum | face savoring food
😛 faceface | stuck_out_tongue | face with tongue
😜 faceface | stuck_out_tongue_winking_eye | winking face with tongue
🤪 faceface | zany_face | zany face
😝 faceface | stuck_out_tongue_closed_eyes | squinting face with tongue
🤑 faceface | money_mouth_face | money-mouth face
🤗 faceface | hugging_face | hugging face
🤭 faceface | hand_over_mouth | face with hand over mouth
🤫 faceface | shushing_face | shushing face
🤔 faceface | thinking_face | thinking face
🤐 faceface | zipper_mouth_face | zipper-mouth face
🤨 faceface | eyebrow | face with raised eyebrow
😐 faceface | neutral_face | neutral face
😑 faceface | expressionless | expressionless face
😶 faceface | no_mouth | face without mouth
😏 faceface | smirk | smirking face
😒 faceface | unamused | unamused face
🙄 faceface | roll_eyes | face with rolling eyes
😬 faceface | grimacing | grimacing face
🤥 faceface | lying_face | lying face
😌 faceface | relieved | relieved face
😔 faceface | pensive | pensive face
😪 faceface | sleepy | sleepy face
🤤 faceface | drooling_face | drooling face
😴 faceface | sleeping | sleeping face
😷 faceface | mask | face with medical mask
🤒 faceface | thermometer_face | face with thermometer
🤕 faceface | bandage_face | face with head-bandage
🤢 faceface | nauseated_face | nauseated face
🤮 faceface | vomiting_face | face vomiting
🤧 faceface | sneezing_face | sneezing face
🥵 faceface | hot_face | hot face
🥶 faceface | cold_face | cold face
🥴 faceface | woozy_face | woozy face
😵 faceface | dizzy_face | dizzy face
🤯 faceface | exploding_head | exploding head
🤠 faceface | cowboy_hat_face | cowboy hat face
🥳 faceface | partying_face | partying face
😎 faceface | sunglasses | smiling face with sunglasses
🤓 faceface | nerd_face | nerd face
🧐 faceface | monacle_face | face with monocle
😕 faceface | confused | confused face
😟 faceface | worried | worried face
🙁 faceface | slightly_frowning_face | slightly frowning face
😮 faceface | open_mouth | face with open mouth
😯 faceface | astonished | astonished face
😲 faceface | astonished | astonished face
😳 faceface | flushed | flushed face
🥺 faceface | pleading_face | pleading face
😦 faceface | frowning | frowning face with open mouth
😧 faceface | anguished | anguished face
😨 faceface | fearful | fearful face
😰 faceface | cold_sweat | anxious face with sweat
😥 faceface | disappointed_relieved | sad but relieved face
😢 faceface | cry | crying face
😭 faceface | sob | loudly crying face
😱 faceface | scream | face screaming in fear
😖 faceface | confounded | confounded face
😣 faceface | perseverance | persevering face
😩 faceface | weary | weary face
😫 faceface | tired_face | tired face
🥱 faceface | yawning_face | yawning face
😤 faceface | triumph | face with steam from nose
😡 faceface | rage | pouting face
😠 faceface | angry | angry face
🤬 faceface | cursing_face | face with symbols over mouth
😈 faceface | smiling_imp | smiling face with horns
👿 faceface | imp | angry face with horns
💀 faceface | skull | skull
☠️ faceface | skull_and_crossbones | skull and crossbones
💩 faceface | poop | pile of poo
🤡 faceface | clown_face | clown face
👹 faceface | ogre | ogre
👺 faceface | goblin | goblin
👻 faceface | ghost | ghost
👽 faceface | alien | alien
👾 faceface | space_invader | alien monster
🤖 faceface | robot | robot face
😺 faceface | smiley_cat | grinning cat face with smiling eyes
😸 faceface | smile_cat | grinning cat face
😹 faceface | joy_cat | cat face with tears of joy
😻 faceface | heart_eyes_cat | smiling cat face with heart-eyes
😼 faceface | smirk_cat | cat face with wry smile
😽 faceface | kiss_cat | kissing cat face
🙀 faceface | scream_cat | weary cat face
😿 faceface | crying_cat_face | crying cat face
😾 faceface | pouting_cat | pouting cat face
