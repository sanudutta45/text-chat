export default SendMessageForm = {
  mounted() {
    const inputElm = this.el.querySelector("#message_text")
    const sendMsgElm = this.el.querySelector("#send_msg_btn")
    inputElm.addEventListener("input", () => {
      if (inputElm.value.trim() !== "") sendMsgElm.disabled = false
      else sendMsgElm.disabled = true
    })
  },
}
