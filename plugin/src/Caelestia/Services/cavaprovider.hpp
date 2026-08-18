#pragma once

#include "audioprovider.hpp"
#include <cava/cavacore.h>
#include <qqmlintegration.h>

namespace caelestia::services {

class CavaProcessor : public AudioProcessor {
    Q_OBJECT

public:
    explicit CavaProcessor(QObject* parent = nullptr);
    ~CavaProcessor();

    void setBars(int bars);

signals:
    void valuesChanged(QVector<double> values);

protected:
    void process() override;

private:
    struct cava_plan* m_plan;
    double* m_in;
    double* m_out;

    int m_bars;
    QVector<double> m_values;

    void reload();
    void initCava();
    void cleanup();
};

class CavaProvider : public AudioProvider {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int bars READ bars WRITE setBars NOTIFY barsChanged)

    Q_PROPERTY(QVector<double> values READ values NOTIFY valuesChanged)

    // Change token for QML bindings. Reading `values` from QML attaches a
    // ReferenceObject to this notifier that is only released on JS GC, so bind
    // to `revision` and pull the data via readValues() instead.
    Q_PROPERTY(uint revision READ revision NOTIFY valuesChanged)

public:
    explicit CavaProvider(QObject* parent = nullptr);

    [[nodiscard]] int bars() const;
    void setBars(int bars);

    [[nodiscard]] QVector<double> values() const;

    [[nodiscard]] uint revision() const;

    // Q_INVOKABLE return values are not attached to a property, so this creates
    // no reference and no notifier endpoint.
    Q_INVOKABLE [[nodiscard]] QVector<double> readValues() const;

signals:
    void barsChanged();
    void valuesChanged();

private:
    int m_bars;
    QVector<double> m_values;
    uint m_revision;

    void updateValues(QVector<double> values);
};

} // namespace caelestia::services
