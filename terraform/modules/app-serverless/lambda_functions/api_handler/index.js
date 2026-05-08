exports.handler = async (event) => {
  const response = {
    message: "cloudlaunch-zero API response",
    method: event.requestContext?.http?.method || "UNKNOWN",
    path: event.rawPath || "/",
    requestId: event.requestContext?.requestId || "n/a",
    timestamp: new Date().toISOString(),
  };

  return {
    statusCode: 200,
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify(response),
  };
};
