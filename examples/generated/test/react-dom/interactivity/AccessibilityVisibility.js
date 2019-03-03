// Generated by Lona Compiler 0.5.3

import React from "react"
import styled from "styled-components"

import colors from "../foundation/colors"
import shadows from "../foundation/shadows"
import textStyles from "../foundation/textStyles"
import { isFocused, focusFirst, focusLast, focusNext, focusPrevious } from
  "../utils/focusUtils"

export default class AccessibilityVisibility extends React.Component {
  state = { focusRing: false }

  setFocusRing = (focusRing) => { this.setState({ focusRing }) }

  isFocused = () => {
    let focusElements = this._getFocusElements()

    return !!focusElements.find(isFocused);
  }

  focus = ({ focusRing = true } = { focusRing: true }) => {
    this.setFocusRing(focusRing)

    return focusFirst(this._getFocusElements());
  }

  focusLast = ({ focusRing = true } = { focusRing: true }) => {
    this.setFocusRing(focusRing)

    return focusLast(this._getFocusElements());
  }

  focusNext = ({ focusRing = true } = { focusRing: true }) => {
    this.setFocusRing(focusRing)

    return focusNext(this._getFocusElements());
  }

  focusPrevious = ({ focusRing = true } = { focusRing: true }) => {
    this.setFocusRing(focusRing)

    return focusPrevious(this._getFocusElements());
  }

  _handleKeyDown = (event) => {
    if (event.key === "Tab") {
      this.setFocusRing(true)

      if (event.shiftKey) {
        if (this.focusPrevious()) {
          event.stopPropagation()
          event.preventDefault()
          return ;
        } else if (this.props.onFocusExitPrevious) {
          this.props.onFocusExitPrevious()

          event.stopPropagation()
          event.preventDefault()
          return ;
        }
      } else if (this.focusNext()) {
        event.stopPropagation()
        event.preventDefault()
        return ;
      } else if (this.props.onFocusExitNext) {
        this.props.onFocusExitNext()

        event.stopPropagation()
        event.preventDefault()
        return ;
      }
    }

    if (this.props.onKeyDown) {
      this.props.onKeyDown(event)
    }
  }

  _getFocusElements = () => {
    let elements = [this._GreyBox, this._Text]
    return elements.filter(Boolean);
  }

  render() {


    let Text$visible

    Text$visible = this.props.showText
    return (
      <View>
        <GreyBox
          aria-label={"Grey box"}
          tabIndex={-1}
          className={(
            this.state.focusRing
              ? "lona--focus-ring"
              : "lona--no-focus-ring"
          )}
          onKeyDown={this._handleKeyDown}
          ref={(ref) => { this._GreyBox = ref }}

        />
        {
          Text$visible &&
          <Text
            aria-label={"Some text that is sometimes hidden"}
            tabIndex={-1}
            className={(
              this.state.focusRing
                ? "lona--focus-ring"
                : "lona--no-focus-ring"
            )}
            onKeyDown={this._handleKeyDown}
            ref={(ref) => { this._Text = ref }}
          >
            {"Sometimes hidden"}
          </Text>
        }
      </View>
    );
  }
};

let View = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let GreyBox = styled.div({
  alignItems: "flex-start",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  width: "100px",
  height: "40px"
})

let Text = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})