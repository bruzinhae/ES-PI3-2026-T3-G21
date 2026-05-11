import { setGlobalOptions } from "firebase-functions/v2";

setGlobalOptions({ maxInstances: 10 });

export * from "./startups";
export * from "./users";
export * from "./wallet";
export * from "./tokens";
export * from "./exchange";