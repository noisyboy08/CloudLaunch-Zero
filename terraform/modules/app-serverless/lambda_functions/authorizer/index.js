exports.handler = async (event) => {
  const expected = process.env.API_TOKEN || "";
  const incoming = event.headers?.authorization || event.headers?.Authorization || "";

  const isAuthorized = expected.length > 0 && incoming === `Bearer ${expected}`;

  return {
    isAuthorized,
    context: {
      principalId: isAuthorized ? "authorized-user" : "anonymous",
    },
  };
};
