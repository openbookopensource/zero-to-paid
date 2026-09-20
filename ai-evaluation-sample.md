# AI Evaluation Sample

## Purpose

This is an illustrative example of evaluating an AI-generated answer for accuracy, completeness, safety, and usefulness.

The response below is **synthetic** and created for demonstration purposes. It is not presented as output from a real client or production system.

---

## Evaluation Task

**User question:**

> A company wants to use an AI assistant to summarise confidential internal documents. What are three important security risks they should consider?

### Synthetic AI response

> The three main risks are:
>
> 1. The AI may give incorrect summaries.
> 2. Employees may use weak passwords.
> 3. The AI could become unavailable if the internet goes down.
>
> To reduce these risks, the company should use a reliable AI provider and make sure employees follow good security practices.

---

## Evaluation

### 1. Accuracy

**Assessment: Partially acceptable**

The response identifies genuine operational concerns, but it does not identify the most important security risks associated specifically with confidential documents being processed by an AI system.

The password and internet-availability points are possible concerns, but they are not the most directly relevant risks raised by the scenario.

### 2. Completeness

**Assessment: Weak**

Important risks are missing, including:

* Confidential information being exposed to an AI provider or other unauthorised party.
* Sensitive information being retained or used inappropriately.
* Access controls failing and allowing users to retrieve documents they should not see.
* Sensitive information appearing in prompts, logs, outputs, or other system components.
* Incorrect AI output causing sensitive information to be disclosed or misunderstood.

### 3. Relevance

**Assessment: Partially acceptable**

The answer is related to security, but two of its three main points are relatively generic. A stronger answer would focus on risks created by combining **confidential data + AI processing**.

### 4. Safety

**Assessment: Acceptable but incomplete**

The response does not provide dangerous instructions. However, its general recommendations could create false confidence because they do not address data governance, access control, retention, or information leakage.

### 5. Overall judgement

**Needs improvement**

The answer is understandable and contains some valid security observations, but it fails to focus on the central risks in the scenario.

---

## Example of an improved answer

Three important risks are:

1. **Data exposure** — confidential documents or prompts could be exposed to an unauthorised person or third-party service.
2. **Access-control failures** — users or systems could gain access to documents or information outside their authorised permissions.
3. **Information leakage or incorrect handling** — sensitive information could appear in AI outputs, logs, stored prompts, or other system components, while inaccurate summaries could also lead to poor security decisions.

Controls should include appropriate data-handling policies, access controls, vendor/security assessment, retention controls, monitoring, and human review for sensitive use cases.

---

## Evaluation dimensions demonstrated

This sample evaluates an AI response against:

* Accuracy
* Completeness
* Relevance
* Safety
* Practical usefulness
* Ability to identify omissions
* Ability to distinguish generic advice from scenario-specific risks

**Status:** Demonstration sample — not independently validated against a production evaluation benchmark.

