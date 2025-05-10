$(document).ready(() => {
  $.post(`http://bs-lib/isReady`, []);

  const actions = {
    hoverfy: ({ data }) => {
      if (data.show) $("#hoverfy").show();
      else $("#hoverfy").hide();

      if (data.key) $("#hoverfy-key").text(data.key);

      if (data.text) $("#hoverfy-text").text(data.text);
    },
  };

  window.addEventListener("message", (event) => {
    const { action } = event.data;
    if (actions[action]) actions[action](event.data);
  });
});
