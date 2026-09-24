// components/base/MenuList.qml
import QtQuick
import QtQuick.Controls
import qs.core

// Shared scrollable row list: caps height at `maxVisible` rows. Delegates must use `width: ListView.view.width`.
ListView {
    id: root

    property int maxVisible: 5

    width: parent.width
    clip:  true

    height: {
        if (count <= maxVisible) return contentHeight
        let item = contentItem.children[0]
        if (!item) return maxVisible * 48
        return (item.height * maxVisible) + (spacing * (maxVisible - 1))
    }

    ScrollBar.vertical: ScrollBar {
        policy: root.count > root.maxVisible ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff

        contentItem: Rectangle {
            implicitWidth: 4
            radius:        2
            color:         Theme.overlay
        }
        background: Item {}
    }
}
