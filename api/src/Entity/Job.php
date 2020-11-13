<?php

namespace App\Entity;

use ApiPlatform\Core\Annotation\ApiFilter;
use ApiPlatform\Core\Annotation\ApiProperty;
use ApiPlatform\Core\Annotation\ApiResource;
use ApiPlatform\Core\Bridge\Doctrine\Orm\Filter\SearchFilter;
use App\Repository\JobRepository;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;
use Doctrine\ORM\Mapping as ORM;
use App\Filter\JobDistanceFilter;
use Symfony\Component\Serializer\Annotation\Groups;
use App\Dto\Job\JobInput;

/**
 * @ApiResource(
 *     normalizationContext={"groups"={"read", "job:read"}},
 *     denormalizationContext={"groups"={"write", "job:write"}},
 *     collectionOperations={
 *         "get",
 *         "post"={
 *             "method"="POST",
 *             "security"="is_granted('ROLE_CUSTOMER')",
 *             "security_post_denormalize"="is_granted('CREATE_JOB', object)",
 *             "input"=JobInput::class
 *         }
 *     },
 *     itemOperations={
 *         "get",
 *         "put"={
 *             "method"="PUT",
 *             "security"="is_granted('EDIT_JOB', object)",
 *             "input"=JobInput::class
 *         }
 *     }
 * )
 * @ORM\Entity(repositoryClass=JobRepository::class)
 * @ApiFilter(SearchFilter::class, properties={"customer.user"})
 * @ApiFilter(JobDistanceFilter::class, properties={"address.geocoordinates"})
 */
class Job
{
    use Traits\TimestampTrait;

    /**
     * @ORM\Id
     * @ORM\GeneratedValue
     * @ORM\Column(type="integer")
     * @ApiProperty(writable=false)
     * @Groups({"read", "write"})
     */
    protected $id;

    /**
     * @ORM\Column(type="string", length=255)
     * @Groups({"read", "write"})
     */
    protected $title;

    /**
     * @ORM\Column(type="text")
     * @Groups({"read", "write"})
     */
    protected $description;

    /**
     * @ORM\Column(type="boolean", nullable=true)
     * @Groups({"read", "write"})
     */
    protected $immobilized = false;

    /**
     * @ORM\Column(type="integer", nullable=true)
     * @Groups({"read", "write"})
     */
    protected $moving_range;

    /**
     * @var bool
     * @ORM\Column(type="boolean")
     * @Groups({"read", "write"})
     */
    protected $urgent = false;

    /**
     * @var Collection|ServiceTree[]
     * @ORM\ManyToMany(targetEntity="ServiceTree")
     * @Groups({"read"})
     */
    protected $tasks;

    /**
     * @var Customer
     * @ORM\ManyToOne(targetEntity="Customer")
     * @Groups({"job:read"})
     */
    protected $customer;

    /**
     * @var CustomerVehicle
     * @ORM\ManyToOne(targetEntity="CustomerVehicle", cascade={"persist"})
     * @Groups({"job:read"})
     */
    protected $vehicle;

    /**
     * @var Address
     * @ORM\ManyToOne(targetEntity="Address", cascade={"persist", "remove"})
     * @ORM\JoinColumn(nullable=false)
     * @Groups({"job:read"})
     */
    protected $address;

    /**
     * @var JobApplication[]|ArrayCollection
     * @ORM\OneToMany(targetEntity="JobApplication", mappedBy="job")
     */
    protected $applications;

    /**
     * @var JobApplication|null
     * @Groups({"read"})
     * @ApiProperty()
     */
    public $application;

    /**
     * @var int|null
     * @Groups("read")
     * @ApiProperty()
     */
    public $distance;

    /**
     * @var bool|null
     * @Groups("read")
     */
    public $mine;

    public function __construct()
    {
        $this->tasks = new ArrayCollection();
        $this->applications = new ArrayCollection();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getMovingRange(): ?int
    {
        return $this->moving_range;
    }

    public function setMovingRange(?int $moving_range): self
    {
        $this->moving_range = $moving_range;

        return $this;
    }

    public function getTitle(): ?string
    {
        return $this->title;
    }

    public function setTitle(string $title): self
    {
        $this->title = $title;

        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(string $description): self
    {
        $this->description = $description;

        return $this;
    }

    public function getImmobilized(): ?bool
    {
        return $this->immobilized;
    }

    public function setImmobilized(?bool $immobilized): self
    {
        $this->immobilized = $immobilized;

        return $this;
    }

    public function getVehicle(): ?CustomerVehicle
    {
        return $this->vehicle;
    }

    public function setVehicle(?CustomerVehicle $vehicle): self
    {
        $this->vehicle = $vehicle;
        return $this;
    }

    public function getTasks(): Collection
    {
        return $this->tasks;
    }

    public function addTask(ServiceTree $type): self
    {
        if( !$this->tasks->contains($type) ) {
            $this->tasks->add($type);
        }

        return $this;
    }

    public function removeTask(ServiceTree $type): self
    {
        if( $this->tasks->contains($type) ) {
            $this->tasks->remove($type);
        }

        return $this;
    }

    public function getAddress(): ?Address
    {
        return $this->address;
    }

    public function setAddress(?Address $address): self
    {
        $this->address = $address;
        return $this;
    }

    public function isUrgent(): ?bool
    {
        return $this->urgent;
    }

    public function setUrgent(bool $urgent): self
    {
        $this->urgent = $urgent;
        return $this;
    }

    public function getCustomer(): ?Customer
    {
        return $this->customer;
    }

    public function setCustomer(Customer $customer): self
    {
        $this->customer = $customer;
        return $this;
    }

    public function getApplications(): Collection
    {
        return $this->applications;
    }

    public function addApplication(JobApplication $application)
    {
        if (!$this->applications->contains($application)) {
            $this->applications->add($application);
            $application->setJob($this);
        }
        return $this;
    }

    public function removeApplication(JobApplication $application)
    {
        if ($this->applications->contains($application)) {
            $this->applications->remove($application);
        }
        return $this;
    }

}
