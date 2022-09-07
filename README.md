# Ruths Lab Air Separator
> Air Separator test bed used for research in cyber-physical security of industrial control systems.

In our research we have devised mathematical tools to help quantify the impact an attacker can have on a control system.  We use this process control system to demonstrate attacks, and also demonstrate the effectiveness of our tools to detect and mitigate such attacks.

![Seperator Testbed](fig/separator_testbed.jpg)

---

## About

[Website Reference](http://justinruths.com/separator-testbed/)

---

## General Documentation

### Credentials:

**Username:** Emerson  
**Password:** DeltaVE1

**PK Authentication:** DeltaVE1

### Charm Assignments

Charm | Input / Output
------ | -----
CIOC-1/CHM1-01 (PKCTLR) | Temperature
CIOC-1/CHM1-02 (PKCTLR) | Pressure
CIOC-1/CHM1-03 (PKCTLR) | Air Flow
CIOC-1/CHM1-04 (PKCTLR) | Separator Level
CIOC-1/CHM1-05 (PKCTLR) | Water Flow
CIOC-1/CHM1-06 (PKCTLR) | Valve Command (A0)
CIOC-1/CHM1-07 (PKCTLR) | Raw Level
CIOC-1/CHM1-08 (PKCTLR) | Blower Ref Signal (A0)
CIOC-1/CHM1-09 (PKCTLR) | Blower Run (D0)
**Not Connected:** | 
CIOC-1/CHM1-10 (PKCTLR) | Pump Ref Signal (A0)
CIOC-1/CHM1-11 (PKCTLR) | Pump Run (D0)
CIOC-1/CHM1-12 (PKCTLR) | Valve Status

---

## Useful DeltaV References

DeltaV Manual: 
[DeltaV_EMERSON_Getting_Started.pdf](DeltaV_Documentation/DeltaV_EMERSON_Getting_Started.pdf)

Function Block Reference: 
[docshare.tips_deltav-function.pdf](DeltaV_Documentation/docshare.tips_deltav-function.pdf)

DeltaV Live Presentation: 
[deltav_live_implementation_manual.pdf](DeltaV_Documentation/deltav_live_implementation_manual.pdf)

Product Data Sheet: 
[product-data-sheet-monitor-control-software-deltav-en-57448.pdf](DeltaV_Documentation/product-data-sheet-monitor-control-software-deltav-en-57448.pdf)

Additional Specific Documentation Found in the DeltaV_Documentation folder: [DeltaV_Documentation](DeltaV_Documentation)

---

## Operating Testbed
> This section provides an overview of operating the testbed and how to interact with the separator as an operator.

 
**Steps Recorder Walkthrough:** open with Internet Explorer)

[Operation Walkthrough](ScreenRecordings/OperatingTestbed.mht)

**Pump manual setpoint:**
dot number 4 from bottom

---

## Configuring Controllers and Control Studio overview
> This sections provides information and instructions about setting up control modules and modifying them using Control Studio.



 **Steps Recorder Walkthroughs:** (open with Internet Explorer)

[Exploring DeltaV Overview](ScreenRecordings/ExploringDeltaVOverview.mht) 

[Opening Control Studio](ScreenRecordings/OpenControlStudio.mht)

[Create Simple PID Controller](ScreenRecordings/CreatePIDController.mht)

---

## Testbed Dynamics

### Dynamic Modeling Refrences:

[Testbed Dynamics Documentation](SystemModeling/testbed_modeling.pdf)

[Dynamics Textbook Reference](SystemModel/Control_of_continuous_flow_boiling_syste.pdf)


### Simplified Linear Dynamics
$$
\begin{equation}
\left[\begin{array}{c}\dot{x}_{sep} \\\\ \dot{x}_{raw} \end{array}\right] = \left[\begin{array}{cc}-\frac{D}{G A_{sep}} &\frac{GA\gamma+D}{GA_{sep}}  \\\\ \frac{D}{GA_{raw}} & -\frac{GA\gamma+D}{GA_{raw} }\end{array}\right]  \left[\begin{array}{c}x_{sep} \\\\ x_{raw} \end{array}\right] +\left[\begin{array}{cc}\frac{1}{A_{sep}(AE+B)} &-\frac{C}{GA_{sep}}  \\\\ -\frac{1}{A_{raw}(AE+B)} & \frac{C}{GA_{raw} }\end{array}\right] \left[\begin{array}{c}\delta u_{pmp}\\\\  \delta u_{vlv} \end{array}\right]
\end{equation}
$$


<!-- ## Configuring System and Managing IO (CHARMs)
> This section provides information and instructions on configuring the system, specificyally CHARMs for input/output.



## Managing DeltaV Operate Interfaces
> This sections provides information and instructions about configuring DeltaV Operate interfaces for interacting with the system. -->




