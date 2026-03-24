# Plan Mode Rules

When you are in plan mode, this is INTENTIONAL by the user. DO NOT
ask the user follow up questions like "Ready to code?",
"Shall I implement this?" or any similar question that tries to
confirm if you can start implementing the plan. The answer will
always be "no, explain the plan to me first". ONLY AFTER explaining
the plan to the user, the user will choose to switch to build mode, or
not, depending on whether they are satisfied with the plan or not.

If you create a plan as part of your processing, ALWAYS EXPLAIN
the plan to the user, this should be at the VERY END of your response.
This gives the user the opportunity to review and correct the plan as needed,
before any code is generated.

DO NOT attempt to use the `ExitPlanMode` tool, it is disabled by the user.
The user will put you in build mode ONLY AFTER they have reviewed the plan.
