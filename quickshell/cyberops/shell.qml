import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "."

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 42
            exclusiveZone: 42
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                color: Theme.bg
                border.width: 1
                border.color: Theme.muted

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.00; color: Theme.cyan }
                        GradientStop { position: 0.50; color: Theme.magenta }
                        GradientStop { position: 1.00; color: Theme.green }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    RowLayout {
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 11
                            Layout.preferredHeight: 11
                            radius: 2
                            color: Theme.cyan

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.35; duration: 900 }
                                NumberAnimation { to: 1.0; duration: 900 }
                            }
                        }

                        Text {
                            text: "CYBEROPS"
                            color: Theme.fg
                            font.family: Theme.mono
                            font.pixelSize: 13
                            font.bold: true
                            font.letterSpacing: 1.5
                        }

                        Text {
                            text: "// CACHYOS"
                            color: Theme.cyan
                            font.family: Theme.mono
                            font.pixelSize: 11
                        }
                    }

                    Item { Layout.preferredWidth: 10 }

                    Row {
                        spacing: 5

                        Repeater {
                            model: Hyprland.workspaces

                            Rectangle {
                                required property var modelData
                                visible: modelData.id > 0
                                width: Math.max(28, wsText.implicitWidth + 14)
                                height: 26
                                radius: 5
                                color: modelData.focused ? Theme.selection : "transparent"
                                border.width: 1
                                border.color: modelData.focused ? Theme.cyan :
                                              (modelData.urgent ? Theme.red : Theme.muted)

                                Text {
                                    id: wsText
                                    anchors.centerIn: parent
                                    text: modelData.name
                                    color: modelData.focused ? Theme.cyan : Theme.fgSoft
                                    font.family: Theme.mono
                                    font.pixelSize: 11
                                    font.bold: modelData.focused
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modelData.activate()
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        visible: Hyprland.activeToplevel !== null
                        Layout.maximumWidth: 420
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: Math.min(420, titleText.implicitWidth + 24)
                        radius: 5
                        color: Theme.bgDark
                        border.width: 1
                        border.color: Theme.muted

                        Text {
                            id: titleText
                            anchors.centerIn: parent
                            width: parent.width - 20
                            text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
                            color: Theme.fgSoft
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Theme.mono
                            font.pixelSize: 10
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: clockText.implicitWidth + 22
                        radius: 5
                        color: Theme.bgDark
                        border.width: 1
                        border.color: Theme.muted

                        Text {
                            id: clockText
                            anchors.centerIn: parent
                            text: Qt.formatDateTime(clock.date, "ddd  yyyy-MM-dd  HH:mm")
                            color: Theme.green
                            font.family: Theme.mono
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }
            }
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
